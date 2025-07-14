# Amazon SageMaker Notebook Instance Cost Estimation

## Overview
This document provides detailed cost estimation for running Amazon SageMaker notebook instances, with specific focus on the **ml.g6.2xlarge** instance type for AI/ML workloads including Stable Diffusion and other GPU-intensive tasks.

## SageMaker Notebook Instance Specifications

### ml.g6.2xlarge Instance Details
- **vCPUs**: 8
- **Memory**: 32 GB
- **GPU**: 1x NVIDIA L4 (24 GB GPU memory)
- **Network Performance**: Up to 25 Gbps
- **EBS Bandwidth**: Up to 8 Gbps
- **Use Cases**: AI/ML training, inference, computer vision, generative AI

## Cost Breakdown (US East - N. Virginia Region)

### 1. Notebook Instance Costs

#### ml.g6.2xlarge Pricing
- **On-Demand Rate**: $1.686 per hour
- **Daily Cost** (24 hours): $40.46
- **Weekly Cost** (7 days): $283.22
- **Monthly Cost** (30 days): $1,213.68
- **Annual Cost** (365 days): $14,767.56

#### Usage Pattern Examples

**Development/Testing (8 hours/day, 5 days/week)**
- Hours per month: ~173 hours
- Monthly cost: $291.68
- Annual cost: $3,500.16

**Research/Experimentation (4 hours/day, 7 days/week)**
- Hours per month: ~120 hours
- Monthly cost: $202.32
- Annual cost: $2,427.84

**Production/Continuous (24/7)**
- Monthly cost: $1,213.68
- Annual cost: $14,767.56

### 2. Storage Costs

#### EBS Volume (Default: 20 GB)
- **gp3 Storage**: $0.08 per GB per month
- **Default 20 GB**: $1.60 per month
- **Recommended 100 GB**: $8.00 per month
- **Large datasets 500 GB**: $40.00 per month

#### Additional Storage Options
- **EFS (if needed)**: $0.30 per GB per month
- **S3 Standard**: $0.023 per GB per month
- **S3 Intelligent Tiering**: $0.0125 per GB per month (for infrequent access)

### 3. Data Transfer Costs

#### Internet Data Transfer
- **First 1 GB/month**: Free
- **Next 9.999 TB/month**: $0.09 per GB
- **Next 40 TB/month**: $0.085 per GB
- **Next 100 TB/month**: $0.07 per GB

#### Typical Usage Scenarios
- **Light usage** (10 GB/month): $0.81
- **Moderate usage** (100 GB/month): $8.91
- **Heavy usage** (1 TB/month): $92.16

## Cost Comparison with EC2 Alternatives

### EC2 g6.2xlarge (from CloudFormation template)
- **On-Demand Rate**: ~$0.8784 per hour
- **Monthly Cost** (24/7): $632.93
- **Additional Costs**: VPC, Security Groups, EBS, Data Transfer

### SageMaker vs EC2 Cost Analysis
| Component | SageMaker ml.g6.2xlarge | EC2 g6.2xlarge |
|-----------|-------------------------|-----------------|
| Compute (24/7) | $1,213.68/month | $632.93/month |
| Storage (100GB) | $8.00/month | $8.00/month |
| Management | Included | Manual setup |
| Jupyter Environment | Pre-configured | Manual setup |
| Auto-stop | Built-in | Custom scripts |
| **Total** | **~$1,221.68/month** | **~$640.93/month** |

## Cost Optimization Strategies

### 1. Lifecycle Management
```python
# Auto-stop configuration
{
    "NotebookInstanceLifecycleConfigName": "auto-stop-config",
    "OnStart": [
        {
            "Content": "#!/bin/bash\necho 'Starting notebook instance'"
        }
    ],
    "OnCreate": [
        {
            "Content": "#!/bin/bash\n# Install additional packages\npip install stable-diffusion-webui"
        }
    ]
}
```

### 2. Scheduled Start/Stop
- Use AWS Lambda + EventBridge to start/stop instances
- Potential savings: 50-70% for development workloads

### 3. Spot Instances (Not available for SageMaker Notebooks)
- Consider SageMaker Training Jobs with Spot instances for batch processing
- Potential savings: Up to 90%

### 4. Right-sizing Recommendations
| Workload Type | Recommended Instance | Monthly Cost (8h/day) |
|---------------|---------------------|----------------------|
| Light Development | ml.t3.medium | $24.19 |
| Medium ML Tasks | ml.m5.xlarge | $69.12 |
| GPU Development | ml.g4dn.xlarge | $152.64 |
| **Heavy AI/ML** | **ml.g6.2xlarge** | **$291.68** |
| Production Training | ml.p4d.24xlarge | $9,331.20 |

## Monthly Budget Planning

### Conservative Estimate (ml.g6.2xlarge)
```
Instance Cost (8h/day, 22 days): $291.68
Storage (100 GB):                 $8.00
Data Transfer (50 GB):            $4.41
Miscellaneous:                    $10.00
--------------------------------
Total Monthly Budget:             $314.09
```

### Aggressive Development (ml.g6.2xlarge)
```
Instance Cost (12h/day, 30 days): $607.68
Storage (500 GB):                  $40.00
Data Transfer (200 GB):            $17.82
Model Storage (S3):                $5.00
--------------------------------
Total Monthly Budget:              $670.50
```

## Cost Monitoring and Alerts

### CloudWatch Billing Alarms
```json
{
    "AlarmName": "SageMaker-Monthly-Budget-Alert",
    "MetricName": "EstimatedCharges",
    "Threshold": 500.00,
    "ComparisonOperator": "GreaterThanThreshold",
    "EvaluationPeriods": 1,
    "Period": 86400
}
```

### AWS Budgets Configuration
- Set up budget alerts at 50%, 80%, and 100% of monthly limit
- Configure automatic actions to stop instances at 90% budget utilization

## Regional Pricing Variations

| Region | ml.g6.2xlarge (per hour) | Monthly Cost (24/7) |
|--------|--------------------------|---------------------|
| US East (N. Virginia) | $1.686 | $1,213.68 |
| US West (Oregon) | $1.686 | $1,213.68 |
| EU (Ireland) | $1.854 | $1,335.29 |
| Asia Pacific (Tokyo) | $2.023 | $1,456.58 |
| Asia Pacific (Sydney) | $2.023 | $1,456.58 |

## Recommendations

### For Stable Diffusion Workloads
1. **Development Phase**: Use ml.g6.2xlarge with auto-stop (8-10 hours/day)
2. **Production Phase**: Consider EC2 with Auto Scaling for cost efficiency
3. **Storage**: Use S3 for model storage, EBS for active datasets
4. **Monitoring**: Set up comprehensive cost monitoring and alerts

### Best Practices
- Always configure auto-stop for development instances
- Use S3 lifecycle policies for model versioning
- Consider SageMaker Training Jobs for batch processing
- Implement proper IAM policies to prevent unauthorized usage
- Regular cost reviews and right-sizing assessments

## Conclusion

The ml.g6.2xlarge instance type is well-suited for AI/ML workloads requiring GPU acceleration. While more expensive than EC2 alternatives, SageMaker provides managed infrastructure, pre-configured environments, and built-in cost optimization features that can justify the premium for many use cases.

**Estimated Monthly Cost Range**: $300 - $1,200 depending on usage patterns.

---
*Last Updated: July 2025*
*Pricing based on US East (N. Virginia) region*
*Prices subject to change - refer to AWS Pricing Calculator for current rates*
