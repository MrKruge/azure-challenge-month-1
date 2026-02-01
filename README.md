# 🚧 Azure Private Networking Troubleshooting Challenge

Welcome to this month's hands-on Azure troubleshooting challenge.

You'll be debugging a real-world Azure networking issue:  
👉 **Accessing Azure services from a private subnet with no internet access.**

Most learners complete this challenge in **30–45 minutes**.

---

## 🧠 Challenge Flow

**Deploy broken infrastructure → Investigate → Fix → Validate → Share your win**

---

## 📖 The Scenario

A development team is building an MVP that relies on:

- **Azure Blob Storage**

Their application needs to:

- Upload files to a Blob Storage container
- Download files from a Blob Storage container
- Delete files from a Blob Storage container

For security and cost reasons, the application must run in a **private subnet**:

- ❌ No public internet access
- ❌ No NAT Gateway
- ✅ Private access only

The infrastructure has already been deployed — but **the application can't connect to storage.**

They’ve asked you to figure out why.

---

## ⚠️ The Problem

The application running on an Azure Virtual Machine returns **connection errors** when attempting to access:

- Azure Blob Storage

There is **no outbound internet access**, and public endpoints are **disabled**.

### ✅ Expected Behavior

The VM in the private subnet should:

- Access Blob Storage privately
- Use Private Endpoints
- Require no internet access

---

## 🛠️ Architecture (High-Level)

- Azure Virtual Network (VNet)
- Private subnet
- Linux VM inside the private subnet
- Storage Account (Blob)
- Private Endpoint for Blob
- Network Security Groups (NSGs)

**Something important is missing… 👀**

---

## 🧑‍💻 Your Mission

### 👉 Step 1: Deploy the Broken Infrastructure

Open Azure Cloud Shell and run:

```bash
echo "Creating Resource Group CloudClub-Challenge2.."
az group create \
  --name "CloudClub-Challenge2" \
  --location westeurope
  
curl -o challenge.bicep https://raw.githubusercontent.com/MrKruge/azure-challenge-month-1/refs/heads/main/Month-01/month-1.bicep

az deployment group create \
  --resource-group CloudClub-Challenge2 \
  --template-file challenge.bicep \
  --parameters adminPassword='hjErTzzsZWT5BjmWxXNV'
```

Wait for the deployment to complete successfully.

### 👉 Step 2: Investigate

Your goal is to determine **why the VM cannot reach Blob Storage.**

Start by checking:

- Storage account networking settings
- Private Endpoint configuration
- DNS resolution from inside the VM
- How Azure resolves service names when using Private Endpoints
- Network Security Groups (NSGs)

💡 **Hint:**  
Private Endpoints change where traffic goes — but not how names resolve.

Ask yourself:

> How does a VM in a private subnet resolve `*.blob.core.windows.net`?

### 👉 Step 3: Fix It

Once you identify the issue(s), fix them using the **Azure Portal** or **CLI**.

You may need to configure:

- Private DNS Zones
- VNet links to DNS zones
- Correct name resolution for:
  - `privatelink.blob.core.windows.net`

⚠️ **Do not add:**

- NAT Gateway
- Internet Gateway
- Public network access

That defeats the purpose of the challenge.

### 👉 Step 4: Validate Your Fix

Once fixed, the VM should be able to:

- ✅ Upload a blob
- ✅ Download a blob
- ✅ Delete a blob

**💡 Test your fix by SSH'ing into the VM and running:**

First, create a test container (if it doesn't exist):
```bash
az storage container create --account-name <YOUR_STORAGE_ACCOUNT> --name test --auth-mode login
```

Then upload a test file:
```bash
az storage blob upload \
  --account-name <YOUR_STORAGE_ACCOUNT> \
  --container-name test \
  --name challenge.bicep \
  --file challenge.bicep \
  --auth-mode login
```

Replace `<YOUR_STORAGE_ACCOUNT>` with your actual storage account name (e.g., `ccstyzkyuxdmthtca`).

If everything works:  
🎉 **Challenge solved**

*(If a validation script or function is provided, run it now.)*

### 👉 Step 5: Clean Up

⚠️ **Important:**  
Delete any resources you created manually before deleting the resource group.

Then run:

```bash
az group delete \
  --name CloudClub-Challenge2 \
  --yes --no-wait
```

Wait for the resource group to be fully deleted.

---

## 🆘 Stuck? Good.

That means you're learning.

Post in **#stuck** with:

- What you've checked so far
- What you expected to see
- What you're actually seeing

### How we help each other here:

- ❌ Don't ask for the answer
- ✅ Ask for a nudge
- ❌ Don't give answers
- ✅ Give hints and direction

That’s how real troubleshooting skills are built.

---

## 🏆 You Did It. Share Your Win!

Head to **#wins** and post:

- A screenshot or description of your success
- What you checked first
- Your "aha" moment (keep it spoiler-free!)

A few sentences is perfect.