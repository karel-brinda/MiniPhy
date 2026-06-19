import subprocess
import sys
from pathlib import Path


CREATE_BATCHES = Path(__file__).resolve().parents[1] / "create_batches.py"


def write_metadata(path, rows):
    lines = ["species\tfilename"]
    lines.extend(f"{species}\t{filename}" for species, filename in rows)
    path.write_text("\n".join(lines) + "\n")


def run_create_batches(metadata, output_dir):
    output_dir.mkdir()
    return subprocess.run(
        [
            sys.executable,
            str(CREATE_BATCHES),
            str(metadata),
            "-d",
            str(output_dir),
            "-m",
            "2",
            "-M",
            "10",
            "-D",
            "10",
        ],
        capture_output=True,
        text=True,
    )


def test_writes_one_batch_for_two_genomes_from_same_species(tmp_path):
    metadata = tmp_path / "metadata.tsv"
    output_dir = tmp_path / "batches"
    write_metadata(
        metadata,
        [
            ("Example species", "genome-1.fasta"),
            ("Example species", "genome-2.fasta"),
        ],
    )

    result = run_create_batches(metadata, output_dir)

    assert result.returncode == 0, result.stderr
    batch_files = list(output_dir.glob("*.txt"))
    assert len(batch_files) == 1
    assert batch_files[0].read_text().splitlines() == [
        "genome-1.fasta",
        "genome-2.fasta",
    ]
