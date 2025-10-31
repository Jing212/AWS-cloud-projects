# AWS-cloud-projects

This project simulates a real-world consulting workflow for international students can submit their basic information and preference online, receive personalized school/service "match buckets,", and submit an inquiry for consultant follow-up.

The platform is fully deployed on AWS using Terraform with a secure, cost-efficient, and pricate-only network design (NO-NAT) 

## Architecture Overview
Stack: VPC → Security Groups → ALB → EC2 App → RDS → CloudWatch + SNS  
IaC: Terraform

## How it works 
1. Students fills out a form with their GPA, English Proficiency test results (TOEFL/IELTS), their regions, butget and interests.
2. Backend applies rules to generate: reach/target/safety match buckets & recommended service.
3. Students submit an inquiry, it will stored in RDS.
4. Consultant reviews and follows up.

## AWS Components Breakdown
### **VPC & Networking**
- 2 Avaliablity Zones
- Public subnets
- Private subnets for EC2 and RDS
- **No Nat GATEWAY**
- **VPC Engpoints:**
 - S3 (Gateway)
 - SSM, EC2Messages, SSMessages, CloudWatch Logs

 ### **Security Groups**
 | SG | Allows | Purpose |
|----|--------|-----------|
| **ALB-SG** | 80/443 from internet | Public entry |
| **EC2-SG** | Only from ALB-SG | Protect app layer |
| **RDS-SG** | Only from EC2-SG | Private DB access |

### **Compute & App**
- ALB → Target Group → EC2 app

### **dATABASE (RDS)**
- Private only
- Encrypted

### **Monitoring & Alerts**
- Cloudwatch Dashboard: ALB, EC2, RDS metrics
- Alarms
- SNS email Notification 