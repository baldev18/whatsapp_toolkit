# 🚀 Flutter Android CI/CD Automation

This project is equipped with a professional, "Senior DevOps" grade CI/CD pipeline using GitHub Actions. It automatically handles code analysis, testing, building, and signing your production APK.

## 🛠️ How to Connect to GitHub

1. Create a **new private repository** on GitHub.
2. Open your terminal in this project folder and run:
   ```bash
   git init
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git add .
   git commit -m "feat: setup modular project and production CI/CD"
   git push -u origin main
   ```

## 🔐 Required GitHub Secrets

You MUST add these secrets in GitHub (**Settings > Secrets and variables > Actions**):

| Secret Name | Description |
| :--- | :--- |
| `ANDROID_KEYSTORE_BASE64` | The Base64 string of your `.jks` file. |
| `ANDROID_KEYSTORE_PASSWORD` | The password for your keystore file. |
| `ANDROID_KEY_ALIAS` | The alias you chose for your key (e.g., `upload`). |
| `ANDROID_KEY_PASSWORD` | The password for the specific key alias. |

## 🔑 How to Create & Prepare your Keystore

### 1. Generate Keystore
Run this in your terminal (keep passwords safe!):
```bash
keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Convert to Base64
GitHub Actions needs the keystore as a string. Convert it:
- **Windows (PowerShell):**
  ```powershell
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File -FilePath keystore_base64.txt
  ```
- **macOS/Linux:**
  ```bash
  base64 -i upload-keystore.jks | pbcopy
  ```
Copy the resulting string and paste it into the `ANDROID_KEYSTORE_BASE64` secret.

## 📦 How to Download the APK

1. Go to the **Actions** tab in your GitHub repository.
2. Click on the latest run titled "Android Production Build".
3. Scroll down to **Artifacts** and download `WhatsApp-Toolkit-Release-APK`.

## ⚠️ Common Issues

- **Missing Secrets**: The build will fail immediately with a clear error if `ANDROID_KEYSTORE_BASE64` is missing.
- **Analysis Errors**: `flutter analyze` is strict. Fix all linting warnings before pushing.
- **Keystore Mismatch**: Ensure the `ANDROID_KEY_ALIAS` matches what you used in the `keytool` command.
