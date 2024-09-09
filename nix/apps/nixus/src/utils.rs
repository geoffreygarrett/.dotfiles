use std::ffi::OsStr;
use std::io::{BufRead, Error, ErrorKind, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitStatus, Output, Stdio};

use log::{debug, error, info, trace};

pub struct CheckedCommand {
    inner: Command,
    live_output: bool,
    env_callback: Option<Box<dyn Fn(&str) -> Option<String>>>,
    sops_file: Option<String>,
    sops_key: Option<String>,
    sops_env_name: Option<String>,
}

impl CheckedCommand {
    pub fn new<S: AsRef<OsStr>>(program: S) -> Result<Self, Error> {
        let program_str = program.as_ref().to_string_lossy();
        let status = Command::new("which")
            .arg(&program)
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status();
        match status {
            Ok(exit_status) if exit_status.success() => Ok(Self {
                inner: Command::new(program),
                live_output: false,
                env_callback: None,
                sops_file: None,
                sops_key: None,
                sops_env_name: None,
            }),
            _ => Err(Error::new(ErrorKind::NotFound, format!("Command '{}' not found", program_str))),
        }
    }

    pub fn optional_sops_secret<S: AsRef<str>>(self, sops_file: S, key: S) -> Self {
        self.sops_secret_internal(sops_file, key, None, true)
    }

    pub fn optional_sops_secret_with_name<S: AsRef<str>>(self, sops_file: S, key: S, env_name: S) -> Self {
        self.sops_secret_internal(sops_file, key, Some(env_name), true)
    }

    pub fn sops_secret<S: AsRef<str>>(self, sops_file: S, key: S) -> Self {
        self.sops_secret_internal(sops_file, key, None, false)
    }

    pub fn sops_secret_with_name<S: AsRef<str>>(self, sops_file: S, key: S, env_name: S) -> Self {
        self.sops_secret_internal(sops_file, key, Some(env_name), false)
    }


    fn sops_secret_internal<S: AsRef<str>>(mut self, sops_file: S, key: S, env_name: Option<S>, optional: bool) -> Self {
        let sops_file = sops_file.as_ref().to_string();
        let key = key.as_ref().to_string();
        let env_name = env_name.map(|s| s.as_ref().to_string())
            .unwrap_or_else(|| key.to_uppercase().replace('-', "_"));

        self.sops_file = Some(sops_file);
        self.sops_key = Some(key);
        self.sops_env_name = Some(env_name);

        self
    }

    fn apply_sops_secret(&mut self) -> Result<(), Error> {
        if let (Some(sops_file), Some(key), Some(env_name)) = (&self.sops_file, &self.sops_key, &self.sops_env_name) {
            let output = Command::new("sops")
                .args(&["-d", sops_file, "--extract", &format!("[\"{}\"]", key)])
                .output()?;

            if output.status.success() {
                let secret = String::from_utf8(output.stdout)
                    .map_err(|e| Error::new(ErrorKind::InvalidData, e))?
                    .trim()
                    .to_string();
                println!("Setting environment variable {} with secret from SOPS", env_name);
                self.inner.env(env_name, secret);
            } else {
                eprintln!("Warning: Failed to extract SOPS secret for key: {}", key);
            }
        }
        Ok(())
    }


    pub fn with_live_output(mut self) -> Self {
        self.live_output = true;
        self
    }

    pub fn with_env_callback<F>(mut self, callback: F) -> Self
    where
        F: Fn(&str) -> Option<String> + 'static,
    {
        self.env_callback = Some(Box::new(callback));
        self
    }
    pub fn arg<S: AsRef<OsStr>>(mut self, arg: S) -> Self {
        self.inner.arg(arg);
        self
    }

    pub fn args<I, S>(mut self, args: I) -> Self
    where
        I: IntoIterator<Item=S>,
        S: AsRef<OsStr>,
    {
        self.inner.args(args);
        self
    }

    pub fn current_dir<P: AsRef<Path>>(mut self, dir: P) -> Self {
        self.inner.current_dir(dir);
        self
    }

    pub fn env<K, V>(mut self, key: K, val: V) -> Self
    where
        K: AsRef<OsStr>,
        V: AsRef<OsStr>,
    {
        let key_str = key.as_ref().to_str().unwrap_or("");
        if let Some(ref callback) = self.env_callback {
            if let Some(new_val) = callback(key_str) {
                self.inner.env(key, new_val);
            } else {
                self.inner.env(key, val);
            }
        } else {
            self.inner.env(key, val);
        }
        self
    }

    pub fn envs<I, K, V>(mut self, vars: I) -> Self
    where
        I: IntoIterator<Item=(K, V)>,
        K: AsRef<OsStr>,
        V: AsRef<OsStr>,
    {
        self.inner.envs(vars);
        self
    }

    pub fn stdin<T: Into<Stdio>>(mut self, cfg: T) -> Self {
        self.inner.stdin(cfg);
        self
    }

    pub fn stdout<T: Into<Stdio>>(mut self, cfg: T) -> Self {
        self.inner.stdout(cfg);
        self
    }

    pub fn stderr<T: Into<Stdio>>(mut self, cfg: T) -> Self {
        self.inner.stderr(cfg);
        self
    }

    pub fn output(mut self) -> Result<Output, Error> {
        self.apply_sops_secret()?;
        if self.live_output {
            let mut child = self.inner.stdout(Stdio::piped()).stderr(Stdio::piped()).spawn()?;

            let stdout = child.stdout.take().unwrap();
            let stderr = child.stderr.take().unwrap();

            let stdout_thread = std::thread::spawn(move || {
                let mut stdout_reader = std::io::BufReader::new(stdout);
                let mut line = String::new();
                while let Ok(bytes) = stdout_reader.read_line(&mut line) {
                    if bytes == 0 {
                        break;
                    }
                    print!("{}", line);
                    line.clear();
                }
            });

            let stderr_thread = std::thread::spawn(move || {
                let mut stderr_reader = std::io::BufReader::new(stderr);
                let mut line = String::new();
                while let Ok(bytes) = stderr_reader.read_line(&mut line) {
                    if bytes == 0 {
                        break;
                    }
                    eprint!("{}", line);
                    line.clear();
                }
            });

            let status = child.wait()?;
            stdout_thread.join().unwrap();
            stderr_thread.join().unwrap();

            if status.success() {
                Ok(Output {
                    status,
                    stdout: Vec::new(),
                    stderr: Vec::new(),
                })
            } else {
                Err(Error::new(ErrorKind::Other, format!("Command failed with exit code: {}", status)))
            }
        } else {
            self.inner.output()
        }
    }


    pub fn status(mut self) -> Result<ExitStatus, Error> {
        self.apply_sops_secret()?;
        self.inner.status()
    }

    pub fn spawn(mut self) -> Result<std::process::Child, Error> {
        self.apply_sops_secret()?;
        self.inner.spawn()
    }
}

pub fn get_custom_locations() -> Vec<String> {
    std::env::var("SOPS_LOCATIONS")
        .map(|s| s.split(':').map(String::from).collect())
        .unwrap_or_default()
}

pub fn ask_for_confirmation(prompt: &str) -> bool {
    print!("{} [y/N]: ", prompt);
    std::io::stdout().flush().unwrap();
    let mut input = String::new();
    std::io::stdin().read_line(&mut input).unwrap();
    input.trim().to_lowercase() == "y"
}

pub fn is_git_repo(path: &Path) -> bool {
    path.join(".git").is_dir()
}

pub fn find_sops_file() -> Result<PathBuf, String> {
    debug!("Searching for SOPS secrets file");
    let current_dir = std::env::current_dir().map_err(|e| format!("Failed to get current directory: {}", e))?;
    debug!("Starting search from current directory: {:?}", current_dir);

    let mut potential_locations = vec![
        "secrets.yaml".to_string(),
        "secrets/secrets.yaml".to_string(),
        ".secrets.yaml".to_string(),
        ".secrets/secrets.yaml".to_string(),
        "config/secrets.yaml".to_string(),
    ];

    potential_locations.extend(get_custom_locations());
    debug!("Searching in locations: {:?}", potential_locations);

    let mut dir = current_dir.as_path();
    loop {
        for location in &potential_locations {
            let file_path = dir.join(location);
            trace!("Checking for SOPS file at: {:?}", file_path);
            if file_path.exists() {
                info!("Found SOPS secrets file at: {:?}", file_path);
                return Ok(file_path);
            }
        }

        if is_git_repo(dir) {
            debug!("Reached Git repository root at: {:?}", dir);
            break;
        }
        if dir.parent().is_none() {
            debug!("Reached filesystem root");
            break;
        }

        dir = dir.parent().unwrap();
        debug!("Moving up to parent directory: {:?}", dir);
    }

    error!("SOPS secrets file not found in any of the expected locations");
    Err("SOPS secrets file not found".to_string())
}
