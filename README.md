# Event Announcement System

**Ivent is a serverless, event-driven architecture for managing and announcing events with automated notifications, built using AWS and Terraform with a robust CI/CD pipeline.**

## 📖 Project Overview

The Event Announcement System is a scalable, secure, and fully automated AWS-based solution designed to manage event creation and notify subscribers via email. It leverages a serverless architecture, a custom VPC for enhanced security, and a CI/CD pipeline for infrastructure-as-code (IaC) deployments. The system supports REST API endpoints for event and subscription management, secured with AWS Cognito authentication, and integrates SNS and SES for real-time notifications.

Key features:
- **Event Management**: Create and store events in DynamoDB with REST APIs.
- **Subscription Handling**: Allow users to subscribe to notifications via email.
- **Automated Notifications**: Trigger email alerts for new events using DynamoDB Streams and SNS.
- **Secure Architecture**: Deploy Lambda functions in private subnets of a custom VPC.
- **CI/CD Automation**: Automate infrastructure updates with CodePipeline and CodeBuild.

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **AWS Lambda** | Serverless compute for event, subscription, and notification logic |
| **AWS API Gateway** | REST API endpoints with Cognito authorization |
| **AWS DynamoDB** | NoSQL database for events and subscriptions |
| **AWS SNS** | Pub/sub messaging for email notifications |
| **AWS SES** | Email delivery for subscriber notifications |
| **AWS VPC** | Custom network with public/private subnets and NAT gateway |
| **AWS Cognito** | User authentication and API security |
| **AWS CodePipeline** | CI/CD pipeline for automated deployments |
| **AWS CodeBuild** | Build and deploy Terraform configurations |
| **AWS S3** | Storage for pipeline artifacts and Terraform state |
| **Terraform** | Infrastructure as Code for provisioning AWS resources |
| **GitHub** | Version control and CI/CD trigger |

## 🏗️ Architecture

The system follows a modular, serverless, and event-driven architecture:

- **Frontend**: API Gateway exposes `/events` and `/subscriptions` endpoints, secured with Cognito JWT authentication.
- **Backend**:
  - **Lambda Functions**: Handle business logic for event creation (`EventManagement`), subscription management (`SubscriptionManagement`), and notification triggering (`NotificationTrigger`).
  - **DynamoDB**: Stores events and subscriptions, with Streams enabled for real-time event detection.
  - **SNS & SES**: Facilitate email subscriptions and notifications.
- **Networking**: A custom VPC with public and private subnets, NAT gateway, and security groups ensures secure Lambda execution.
- **CI/CD**: CodePipeline with CodeBuild automates Terraform plan and apply stages, triggered by GitHub commits.
- **IaC**: Terraform modules (`vpc`, `lambda`, `iam`, `cicd`, etc.) define all infrastructure.

![Architecture Diagram](https://github.com/ankurshashwat/junkyard/blob/b3c736010426d4c1f06a9a0a3053b88bd1c4fc0f/ivent_architecture.PNG)

## 📂 Repository Structure

```plaintext
ivent/
├──backend/
│    ├──main.tf
│    └──variables.tf
├──terraform/
│    ├── main.tf                   # Root Terraform configuration
│    ├── variables.tf              # Root input variables
│    ├── outputs.tf                # Root output values
│    ├── lambda_functions/         # Lambda source code and deployment packages
│    │    ├── event_management/
│    │    ├── subscription_management/
│    │    └── notification_trigger/
│    └── modules/                  # Terraform modules
│         ├── vpc/                 # Custom VPC with subnets and NAT gateway
│         ├── lambda/              # Lambda functions with VPC configuration
│         ├── iam/                 # IAM roles for Lambda, CodePipeline, CodeBuild
│         ├── cicd/                # CI/CD pipeline with CodePipeline and CodeBuild
│         ├── api_gateway/         # API Gateway with REST endpoints
│         ├── sns/                 # SNS topic for notifications
│         ├── dynamodb/            # DynamoDB tables for events and subscriptions
│         ├── cognito/             # Cognito user pool for authentication
│         └── backend/             # S3 buckets for artifacts and state
├── README.md                      # Project documentation
├── .gitignore                     # Git ignore rules
└── buildspec.yml                  # CodeBuild instructions for Lambda packaging
```

## 🚀 Setup Instructions

Follow these steps to fork and set up the project locally:

### Prerequisites

- **AWS Account** with programmatic access (Access Key and Secret Key).
- **Terraform** v1.5.7 or later installed (`terraform -version`).
- **Git** installed (`git --version`).
- **AWS CLI** v2 installed and configured (`aws configure`).
- **Python** 3.9 for Lambda function packaging.
- **GitHub Account** with a forked repository.
- **Node.js** (optional, for API testing with Postman or scripts).

### Steps

1. **Fork the Repository**
   - Fork this repository to your GitHub account.
   - Clone the forked repo locally:
     ```bash
     git clone https://github.com/ankurshashwat/ivent.git
     cd ivent
     ```

2. **Configure AWS Credentials**
   - Set up AWS CLI with your credentials:
     ```bash
     aws configure
     ```
     - Provide Access Key, Secret Key, region (`us-east-1`), and output format (`json`).

3. **Initialize Terraform**
   - Initialize the Terraform working directory:
     ```bash
     terraform init
     ```
     - This configures the S3 backend (`ivent-tf-state-dev`) and DynamoDB lock table (`ivent-tf-lock`).

4. **Set Up Terraform Variables**
   - Create a `terraform.tfvars` file in the root directory:
     ```hcl
     aws_region          = "us-east-1"
     vpc_cidr            = "10.0.0.0/16"
     availability_zones  = ["us-east-1a", "us-east-1b"]
     public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
     private_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]
     github_repo         = "your-username/ivent"
     github_connection_arn = "arn:aws:codestar-connections:us-east-1:your-account-id:connection/your-connection-id"
     ```
     - Replace `your-username`, `your-account-id`, and `your-connection-id` with your values.
     - Obtain `github_connection_arn` from **AWS Console** > **CodePipeline** > **Settings** > **Connections**.

5. **Package Lambda Functions**
   - Navigate to `lambda_functions` and zip each function:
     ```bash
     cd lambda_functions/event_management
     zip -r event_management.zip .
     cd ../subscription_management
     zip -r subscription_management.zip .
     cd ../notification_trigger
     zip -r notification_trigger.zip .
     cd ../../
     ```
   - Ensure `lambda_function.py` exists in each directory (see `lambda_functions` structure).

6. **Deploy Infrastructure**
   - Run Terraform plan to preview changes:
     ```bash
     terraform plan
     ```
   - Apply the configuration:
     ```bash
     terraform apply --auto-approve
     ```
   - Outputs (e.g., `api_gateway_url`, `sns_topic_arn`) will be displayed.

7. **Set Up SES and Cognito**
   - **SES**: Verify sender and recipient emails in **AWS Console** > **SES** > **Verified identities**. Exit sandbox mode for production use.
   - **Cognito**: Create a user in **AWS Console** > **Cognito** > **User Pools** > Select pool > **Users** > **Create user**.
   - Obtain an ID token:
     ```bash
     aws cognito-idp initiate-auth --region us-east-1 --client-id <client_id> --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=<username>,PASSWORD=<password>
     ```

8. **Test the Application**
   - Use Postman to test API endpoints:
     - **POST `/subscriptions`**:
       - URL: `https://<api_id>.execute-api.us-east-1.amazonaws.com/prod/subscriptions`
       - Headers: `Authorization: Bearer <id-token>`, `Content-Type: application/json`
       - Body:
         ```json
         {
           "email": "your-email@gmail.com"
         }
         ```
     - **POST `/events`**:
       - URL: `https://<api_id>.execute-api.us-east-1.amazonaws.com/prod/events`
       - Body:
         ```json
         {
           "title": "Cloud Summit",
           "description": "AWS Conference",
           "date": "2025-08-01"
         }
         ```
   - Check email for subscription confirmation and event notifications.

9. **Test CI/CD Pipeline**
   - Make a change (e.g., add a tag to `modules/lambda/main.tf`):
     ```hcl
     tags = {
       Name        = "EventManagement"
       Environment = "dev-test"
     }
     ```
   - Commit and push:
     ```bash
     git add modules/lambda/main.tf
     git commit -m "Update Lambda tags for testing CI/CD pipeline"
     git push origin main
     ```
   - Monitor pipeline in **AWS Console** > **CodePipeline** > **Pipelines** > `IventPipeline`.

10. **Clean Up**
    - Destroy resources to avoid costs:
      ```bash
      terraform destroy --auto-approve
      ```

## 🧪 Testing and Validation

- **Infrastructure**: Verified VPC, subnets, NAT gateway, and security groups in AWS Console.
- **API Endpoints**: Tested `/subscriptions` and `/events` with Postman, confirming 200 OK responses.
- **Notifications**: Received SNS/SES emails for subscriptions and events.
- **CI/CD**: Triggered pipeline via GitHub commits, validated Terraform plan/apply stages.
- **Security**: Ensured Lambda runs in private subnets with Cognito authentication.

## 📚 Lessons Learned

- **Modular Terraform**: Structured modules for scalability and maintainability.
- **Serverless Security**: Leveraged VPC private subnets for Lambda execution.
- **CI/CD Best Practices**: Implemented plan/apply stages for safe IaC deployments.
- **Event-Driven Design**: Mastered DynamoDB Streams and SNS integration.

## 🚧 Future Improvements

- Add API Gateway request validation and throttling.
- Implement unit tests for Lambda functions.
- Enhance monitoring with CloudWatch dashboards.
- Support multi-region deployment for high availability.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes with descriptive messages.
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

## 📬 Contact

- **Author**: ankurshashwat
- **Email**: ankurshwt@gmail.com
- **LinkedIn**: [ankurshashwat](https://linkedin.com/in/ankurshashwat)

## 📄 License

This project is licensed under the MIT License.
