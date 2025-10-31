# AWS-cloud-projects

This project simulates a real-world consulting workflow for international students can submit their basic information and preference online, receive personalized school/service "match buckets,", and submit an inquiry for consultant follow-up.

The platform is fully deployed on AWS using Terrafor with a secure, cost-efficient, and pricate-only network design (NO-NAT) 

## Architecture Overview
Stack: VPC → Security Groups → ALB → EC2 App → RDS → CloudWatch + SNS  
IaC: Terraform
