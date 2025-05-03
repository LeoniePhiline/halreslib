use std::env::VarError;

use thiserror::Error;

#[derive(Error, Debug)]
pub enum DatabaseError {
    #[error("environment variable '{var_name}' missing: {var_error}")]
    EnvMissing {
        #[source]
        var_error: VarError,
        var_name: String,
    },

    #[error("database error: {0}")]
    Database(#[from] tokio_postgres::Error),

    #[error("database migration error: {0}")]
    Migration(#[from] refinery::Error),
}
