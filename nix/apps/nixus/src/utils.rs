use std::ffi::OsStr;
use std::process::{Command, ExitStatus, Output};

use which::which;

pub struct CheckedCommand {
    inner: Command,
}

impl CheckedCommand {
    pub fn new<S: AsRef<OsStr>>(program: S) -> Result<Self, String> {
        which(program.as_ref()).map_err(|_| format!("Command '{}' not found", program.as_ref().to_string_lossy()))?;
        Ok(Self { inner: Command::new(program) })
    }

    pub fn arg<S: AsRef<OsStr>>(&mut self, arg: S) -> &mut Self {
        self.inner.arg(arg);
        self
    }

    pub fn args<I, S>(&mut self, args: I) -> &mut Self
    where
        I: IntoIterator<Item=S>,
        S: AsRef<OsStr>,
    {
        self.inner.args(args);
        self
    }

    pub fn output(&mut self) -> Result<Output, String> {
        self.inner.output().map_err(|e| format!("Failed to execute command: {}", e))
    }

    pub fn status(&mut self) -> Result<ExitStatus, String> {
        self.inner.status().map_err(|e| format!("Failed to execute command: {}", e))
    }
}