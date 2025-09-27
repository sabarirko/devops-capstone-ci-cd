# 🚀 DevOps Capstone Project – CI/CD Pipeline Automation

## 📌 Project Overview
This project implements a **complete DevOps lifecycle** for the application [hshar/website](https://github.com/hshar/website).  
The goal was to automate **build, test, containerization, and deployment** using industry-standard DevOps tools on AWS.  

---

## 🛠️ Tools & Technologies
- **Version Control:** Git, GitHub  
- **CI/CD:** Jenkins, AWS CodeBuild  
- **Containerization:** Docker  
- **Orchestration:** Kubernetes  
- **Infrastructure as Code:** Terraform  
- **Configuration Management:** Ansible  
- **Cloud:** AWS (EC2, VPC, Auto Scaling, S3, DockerHub)  

---

## ⚙️ Architecture
![Architecture Diagram](screenshots/architecture.png)  
*(Replace with your architecture diagram or screenshot of pipeline)*  

---

## 🚀 Implementation Steps
1. **Git Workflow**  
   - Configured branching strategy for code release.  
   - Release cycle: `develop` branch for testing, `master` branch for production.  

2. **Build & Test**  
   - Configured **AWS CodeBuild** to trigger builds automatically on commits.  
   - Validated application before deployment.  

3. **Dockerization**  
   - Created a **Dockerfile** to containerize the application.  
   - Built custom Docker images and pushed them to **DockerHub**.  

4. **Kubernetes Deployment**  
   - Deployed Dockerized app to **Kubernetes cluster** with **2 replicas**.  
   - Configured a **NodePort service** at port `30008`.  

5. **CI/CD Pipeline with Jenkins**  
   - Created a **Jenkins Pipeline (Jenkinsfile)** with the following stages:  
     - **Build** → Compile & build app  
     - **Test** → Run test cases  
     - **Deploy** → Deploy containerized app to Kubernetes  

6. **Infrastructure Automation**  
   - Used **Terraform** to provision AWS infrastructure.  
   - Applied **Ansible** for software installation & configuration management across nodes.  
