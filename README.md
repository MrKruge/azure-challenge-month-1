# 🔷 Azure - Day 1 Challenge

Welcome to **The Cloud Club**!

Here, we learn by doing — not watching tutorials — by debugging broken cloud infrastructure.

This is your first Azure challenge. It's a warm-up to show you how our challenges work.

**Quick overview:** Deploy broken infrastructure → Find what's wrong → Fix it → Post your win in #wins

---

## 📖 Scenario

A startup developer deployed a simple web server in Azure:

- Ubuntu VM
- NGINX installed
- Public IP
- Virtual Network + Subnet
- Network Security Group (NSG)

But something is wrong. **The web server is not reachable from the internet.**

**Your mission:** figure out what's wrong, fix it, and validate your fix.

---

## ⚠️ Problem

When accessing the web server via the VM's public IP:

```bash
curl http://<PUBLIC_IP>
```

The connection **times out**.

### ✅ Expected Behavior

The web server should be accessible from the internet via HTTP (port 80).

```html
<h1>Cloud Club Azure Challenge</h1>
```

---

## 🧑‍💻 Deployment Instructions

### Step 1: Open Azure Cloud Shell

1. Go to the [Azure Portal](https://portal.azure.com)
2. Click the **Cloud Shell** icon (top-right)
3. Select **Bash**

### Step 2: Create a Resource Group

```bash
echo "Creating Resource Group CloudClub-Challenge1..."
az group create \
  --name "CloudClub-Challenge1" \
  --location westeurope
```
### Step 3: Deploy the Broken Infrastructure

Copy the code and run in the terminal:

```bash
curl -o challenge.bicep https://raw.githubusercontent.com/MrKruge/azure-challenge-day-1/main/day-1-challenge.bicep

az deployment group create \
  --resource-group CloudClub-Challenge1 \
  --template-file challenge.bicep \
  --parameters adminPassword='hjErTzzsZWT5BjmWxXNV'
```

Wait until deployment completes.

**If it fails, figure out why!** 🤔 

### 🕵️ Step 4: Investigate

Check the following Azure resources:

- Virtual Network (VNet)
- Subnet
- Network Security Group (NSG)
- Network Interface (NIC)
- Virtual Machine

💡 **Hint:** Think about how traffic flows from the internet to a VM in Azure.

### Step 5: Fix It

Fix it via the Azure Portal:

1. Go to **Network Security Groups**
2. Find the missing rule / Fix it in the **most secure way**
3. Save and retry accessing the web server

### Step 6: Validate

```bash
curl http://$(az vm show -d -g CloudClub-Challenge1 -n challenge-vm --query publicIps -o tsv)
```

✅ **Success:** The HTML page appears. Challenge solved!

**How can you get the public IP?**

Find out a way to retrieve the public IP address!

### Step 7: Clean Up

```bash
az group delete --name CloudClub-Challenge1 --yes --no-wait
```

---

---

## 🆘 Stuck? Good, that is how we learn.

Real debugging means hitting walls. The skill is knowing how to get unstuck.

Post in **#stuck** with:

- What you've checked so far
- What you're seeing (or not seeing)

**How we help each other here:**  
Don't ask for the answer — ask for a nudge. Don't give answers — give hints.

That's how we all get better.

---

---

## 🏆 Solved it? Now Share Your Win.

Head to **#wins** and post:

- Screenshot of your success message
- What did you check first?
- What was your "aha" moment? (Keep it spoiler-free!)

Don't overthink it — a few sentences is perfect.

This is how we learn here: **by doing, sharing, and helping each other get better.**

See you in the community. 🚀

---
---

## ⚡ Did you share your win? Here's your next step...

You've completed your first challenge. You're not here to watch — you're here to do.

Ready for something harder?

👉 **[This Month's Azure Challenge](../monthly-challenge/Month-01/)**

A new troubleshooting challenge drops every month — each one different, each one harder than Day 1.