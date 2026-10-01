from medrecords.config import Settings


def test_defaults_to_sqlite(monkeypatch):
    monkeypatch.delenv("MEDREC_DATABASE_URL", raising=False)
    assert Settings(_env_file=None).database_url.startswith("sqlite")


def test_database_url_can_be_overridden(monkeypatch):
    monkeypatch.setenv("MEDREC_DATABASE_URL", "postgresql://u:p@localhost/db")
    assert Settings(_env_file=None).database_url.startswith("postgresql")
