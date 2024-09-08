use std::ffi::OsStr;
use std::io::{Error, ErrorKind};
use std::path::Path;
use std::process::{Command, ExitStatus, Output};

pub struct CheckedCommand {
    inner: Command,
}

impl CheckedCommand {
    pub fn new<S: AsRef<OsStr>>(program: S) -> Result<Self, Error> {
        match Command::new(&program).spawn() {
            Ok(mut child) => {
                let _ = child.kill();
                Ok(Self { inner: Command::new(program) })
            }
            Err(e) if e.kind() == ErrorKind::NotFound => {
                Err(Error::new(ErrorKind::NotFound, format!("Command '{}' not found", program.as_ref().to_string_lossy())))
            }
            Err(e) => Err(e),
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

    pub fn output(mut self) -> Result<Output, Error> {
        self.inner.output()
    }

    pub fn status(mut self) -> Result<ExitStatus, Error> {
        self.inner.status()
    }
}