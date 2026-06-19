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


def test_help_describes_metadata_input():
    result = subprocess.run(
        [sys.executable, str(CREATE_BATCHES), "--help"],
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0, f"--help failed:\n{result.stderr}"
    assert "meta_file.tsv" in result.stdout, (
        f"Expected metadata metavar in help output:\n{result.stdout}"
    )
    assert "clustered_fastas.tsv" not in result.stdout, (
        f"Found obsolete metavar in help output:\n{result.stdout}"
    )
    assert "metadata" in result.stdout.lower(), (
        f"Expected metadata description in help output:\n{result.stdout}"
    )
    normalized_help = " ".join(result.stdout.split())
    assert "species and filename columns" in normalized_help, (
        f"Expected required columns in help output:\n{result.stdout}"
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

    assert result.returncode == 0, (
        f"create_batches.py failed:\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}"
    )
    batch_files = list(output_dir.glob("*.txt"))
    assert len(batch_files) == 1, f"Expected one batch file, found: {batch_files}"
    batch_contents = batch_files[0].read_text().splitlines()
    assert batch_contents == [
        "genome-1.fasta",
        "genome-2.fasta",
    ], f"Unexpected batch contents: {batch_contents}"
