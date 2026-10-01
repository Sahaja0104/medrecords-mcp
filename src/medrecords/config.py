from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """App settings, overridable via MEDREC_* environment variables or a .env file."""

    model_config = SettingsConfigDict(env_file=".env", env_prefix="MEDREC_")

    database_url: str = "sqlite:///data/medrecords.db"
    data_dir: Path = Path("data")


settings = Settings()
