# Application Overview — IPYNB to PDF Converter

This application is a multi-service system designed to convert Jupyter Notebook files (.ipynb) into PDF documents through a sequential processing pipeline. It separates each major task into its own service to improve modularity, scalability, and maintainability.

### Main Purpose
The purpose of this application is to:
- Allow users to upload any Jupyter Notebook (.ipynb) file
- Convert the uploaded file into HTML
- Convert the HTML output into a downloadable PDF file


Which is useful for:
- Submitting assignments
- Sharing reports
- Archiving notebooks in a portable format

# How to Run services on Cluster

## Flash the Raspberri Pis

set the Pi's names to `sds01 - sds04`

## Init Cluster

Provide your private key at `../key`

```shell
cd k3s-ansible
ansible-playbook -i ../inventory.yml playbooks/site.yml
```

## Patch the Cluster 
To ensure that core services will run on the control plane,

on the master node 
```sh
chmod +X patch.sh
./patch.sh
```

## Copy Image of the Services to PIs (Optional)
To reduce container's building time 

```sh
ansible -i inventory.yml agent -m file -a "path=/var/lib/rancher/k3s/agent/images/ mode=0755 state=directory owner=root group=root" -b
ansible -i inventory.yml agent -m copy -a "src=/var/lib/rancher/k3s/agent/images/img.tar.gz dest=/var/lib/rancher/k3s/agent/images/ mode=0644 owner=root group=root" -b
ansible -i inventory.yml agent -m unarchive -a "remote_src=yes src=/var/lib/rancher/k3s/agent/images/img.tar.gz dest=/var/lib/rancher/k3s/agent/images/ mode=0644 owner=root group=root" -b
ansible -i inventory.yml agent -m file -a "path=/var/lib/rancher/k3s/agent/images/img.tar.gz state=absent" -b
ansible -i inventory.yml agent -m systemd -a "name=k3s-agent state=restarted" -b
```

## Apply Manifest File

on the master node 

```sh
kubectl apply -f manifest.yaml
```

# How to Run Locally

## Using Docker Compose 
```bash
# Start all services
docker-compose up --build

# Access the frontend at http://localhost
```

## Run Locally (for development)

**Create and activate a venv**
for frontend and html service
```bash
python3 -m venv venv
source venv/bin/activate
```

**Terminal 1 - Frontend:**
```bash
cd frontend
python -m http.server 8000
# Visit http://localhost:8000
```

**Terminal 2 - API Gateway:**
```bash
cd api-gateway
npm install
node gateway.js
```

**Terminal 3 - IPYNB Converter:**
```bash
cd ipynb-html
pip install -r requirements.txt
# Use 1 worker for simplicity, or 2-4 for better performance
gunicorn --bind 0.0.0.0:5000 --workers 2 wsgi:app
```

**Terminal 4 - PDF Service:**
```bash
cd html-pdf
# Install wkhtmltopdf first: apt-get install wkhtmltopdf (Linux) or brew install wkhtmltopdf (Mac)
go run pdf_service.go
```

## Architecture Overview

```
User Browser (Port 80)
    ↓
    → uploads .ipynb file
    ↓
API Gateway (Port 3000, Node.js)
    ↓
    → forwards to Service 3
    ↓
IPYNB→HTML Service (Port 5000, Python)
    ↓
    → returns HTML
    ↓
HTML→PDF Service (Port 8080, Go)
    ↓
    → returns PDF
    ↓
API Gateway → User (PDF download)
```
