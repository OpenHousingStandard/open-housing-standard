from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]


def test_reference_models_have_dry_technical_room():
    configs = sorted(ROOT.glob("reference/ousdal-hus-*/config/house.yaml"))
    assert configs
    for config in configs:
        data = yaml.safe_load(config.read_text())
        assert data["rooms"]["dry_technical_room_m2"] >= 4.0
        assert data["technical_zones"]["dry_technical_room"]["water_installations_allowed"] is False


def test_reference_models_are_single_storey():
    for config in ROOT.glob("reference/ousdal-hus-*/config/house.yaml"):
        data = yaml.safe_load(config.read_text())
        assert data["house"]["floors"] == 1
