use std::ffi::OsStr;
use std::io::{Error, ErrorKind, Write};
use std::path::Path;
use std::process::{Command, ExitStatus, Output, Stdio};

pub struct CheckedCommand {
    inner: Command,
}

impl CheckedCommand {
    pub fn new<S: AsRef<OsStr>>(program: S) -> Result<Self, Error> {
        let program_str = program.as_ref().to_string_lossy();

        // Check if the command exists without actually running it
        let status = Command::new("which")
            .arg(&program)
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status();

        match status {
            Ok(exit_status) if exit_status.success() => Ok(Self { inner: Command::new(program) }),
            _ => Err(Error::new(ErrorKind::NotFound, format!("Command '{}' not found", program_str))),
        }
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
        self.inner.env(key, val);
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
        self.inner.output()
    }

    pub fn status(mut self) -> Result<ExitStatus, Error> {
        self.inner.status()
    }

    pub fn spawn(mut self) -> Result<std::process::Child, Error> {
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