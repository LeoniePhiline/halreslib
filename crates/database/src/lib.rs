use tokio_postgres::{Client, NoTls};

use crate::error::DatabaseError;

pub mod error;

refinery::embed_migrations!("migrations");

type Result<T, E = DatabaseError> = std::result::Result<T, E>;

/// Connects to the database using the host and credentials
/// provided in the following environment variables:
///
/// - `POSTGRES_HOST`
/// - `POSTGRES_USER`
/// - `POSTGRES_PASSWORD`
///
/// Spawns the connection future, which drives communication,
/// as a task onto the runtime.
pub async fn connect() -> Result<Client> {
    let mut config = tokio_postgres::Config::new();

    // Isolate tests by running each test connection
    // in its own `pg_temp_<number>` schema.
    if cfg!(test) {
        config.options("-c search_path=pg_temp");
    }

    let (client, connection) = config
        .host(env("POSTGRES_HOST")?)
        .user(env("POSTGRES_USER")?)
        .password(env("POSTGRES_PASSWORD")?)
        .connect(NoTls)
        .await?;

    tokio::spawn(async move {
        if let Err(err) = connection.await {
            eprintln!("connection error: {}", err);
        }
    });

    Ok(client)
}

/// Performs database migrations,
/// executing the versioned migration scripts
/// in the crate's `./migrations` directory,
/// while keeping track of already executed mgirations.
pub async fn migrate(client: &mut Client) -> Result<()> {
    migrations::runner().run_async(client).await?;

    Ok(())
}

/// Wraps `std::env::var` with error handling.
fn env(name: &str) -> Result<String> {
    std::env::var(name).map_err(|var_error| {
        let var_name = name.to_owned();
        DatabaseError::EnvMissing {
            var_error,
            var_name,
        }
    })
}

#[cfg(test)]
mod tests {
    use pretty_assertions::assert_eq;
    use regex::Regex;
    use serde::Serialize;
    use tokio_postgres::Row;

    use super::*;

    #[tokio::test]
    async fn connects_to_postgres() -> Result<()> {
        let client = connect().await?;

        let value: i32 = client.query_one("SELECT 1", &[]).await?.try_get(0)?;

        assert_eq!(value, 1);

        Ok(())
    }

    #[tokio::test]
    async fn migrates_schema() -> Result<()> {
        #[derive(Serialize)]
        struct PgTable {
            schema_name: String,
            table_name: String,
            table_owner: String,
            table_space: Option<String>,
            has_indexes: bool,
            has_rules: bool,
            has_triggers: bool,
            row_security: bool,
        }

        impl PgTable {
            fn from_row(row: &Row) -> Result<Self> {
                Ok(Self {
                    schema_name: row.try_get(0)?,
                    table_name: row.try_get(1)?,
                    table_owner: row.try_get(2)?,
                    table_space: row.try_get(3)?,
                    has_indexes: row.try_get(4)?,
                    has_rules: row.try_get(5)?,
                    has_triggers: row.try_get(6)?,
                    row_security: row.try_get(7)?,
                })
            }
        }

        let mut client = connect().await?;

        migrate(&mut client).await?;

        let value: Vec<PgTable> = client
            .query(
                "
                SELECT *
                FROM pg_catalog.pg_tables
                WHERE schemaname != 'pg_catalog' AND
                    schemaname != 'information_schema'
                ",
                &[],
            )
            .await?
            .iter()
            .map(PgTable::from_row)
            .collect::<Result<Vec<_>>>()?;

        insta::assert_ron_snapshot!(&value, {
            "[].schema_name" => insta::dynamic_redaction(|value, _path| {
                let value = value.as_str().unwrap();
                let regex = r"pg_temp_\d+";

                assert_eq!(
                    Regex::new(regex).unwrap().is_match(value),
                    true,
                    "value '{}' did not match regular expression '{}'",
                    value, regex
                );
                "pg_temp_<number>"
            })
        });

        Ok(())
    }
}
