import os

# Base directory
BASE_DIR = "lib"

# Folder structure definition
structure = {
    BASE_DIR: [
        "main.dart",
        {
            "controllers": [],

            "data": [
                {"models": []},
                {"services": []}
            ],

            "utils": [
                "bindings.dart",
                "constants.dart",
                "helpers.dart",
                "validators.dart"
            ],

            "presentation": [
                {
                    "screens": [
                        {"auth": ["login_screen.dart", "signup_screen.dart"]},
                        # add other screens here as needed
                    ]
                },
                {"widgets": []}
            ]
        }
    ]
}


def create_structure(base_path, tree):
    """Recursively create directories and files based on structure definition."""
    for item in tree:
        if isinstance(item, str):
            # Create file
            file_path = os.path.join(base_path, item)
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(f"// {os.path.basename(file_path)}\n")
            print(f"📄 Created file: {file_path}")
        elif isinstance(item, dict):
            # Create directories
            for folder_name, contents in item.items():
                folder_path = os.path.join(base_path, folder_name)
                os.makedirs(folder_path, exist_ok=True)
                print(f"📁 Created folder: {folder_path}")
                create_structure(folder_path, contents)


def main():
    print("🚀 Creating Flutter folder structure...")
    for root, contents in structure.items():
        os.makedirs(root, exist_ok=True)
        print(f"📂 Root directory: {root}")
        create_structure(root, contents)
    print("\n✅ Flutter structure created successfully!")


if __name__ == "__main__":
    main()
