# Chapter 4: CI/CD

—

## Introduction

CI/CD is essential for managing Databricks deployments reliably and repeatably.  
It enables consistent deployment of infrastructure, notebooks, jobs, and other assets across environments, while s manual steps and ensuring auditability.

—

## Infrastructure as Code (IaC)

Databricks workspaces and associated resources are best deployed using **Infrastructure as Code (IaC)**.  
The **Security Reference Architecture (SRA) GitHub repository** provides examples for **Azure, AWS, and GCP** and is written in Terraform, which is widely adopted and fully supported by Databricks.

**Benefits of IaC include:**

- Consistent and repeatable deployments of workspaces, clusters, networks, and permissions.  
- Version-controlled infrastructure that can be audited.  
- Simplified replication of environments (development, test, staging, production).  

Deploying IaC through CI/CD pipelines is a best practice to maintain consistency and reduce the risk of human error.

There are a few things that Terraform does not support these are mostly workspace and account options which have to be manually change, but suspect Terraform support won’t be far away.

A typical simple infrastructure deployment might look something like this



—

## Databricks Asset Bundles (DAB)

**Databricks Asset Bundles (DAB)** provides a structured and automated way to deploy assets to Databricks.  
It is now the recommended approach for production deployments and supports notebooks, libraries, jobs, clusters, and other workspace resources.

### Setup

- Install the DAB CLI:  
    pip install databricks-asset-bundles

- Authenticate using a **service principal** credentials.  

- Initialize a new project:  
    dab init my_project

  This creates the standard folder structure for notebooks, libraries, jobs, and other assets.

### Development Flow

- **Development Workspace**: Assets are developed in a workspace and organized into logical folders or schemas.  

- **Deploy to Development**: Use the DAB CLI to deploy assets to the development workspace:  
    dab deploy —workspace <workspace-name> —env dev
The default behaviour of DAB is to deploy assets with the <user>_ prefix.  Although you can overwrite this behavior this can be really helpful for creating slimCI environments so each engineer can develop their own logical (normally by schema) isolated 'local' environment.  In this scenerio you can consider development as actual two environments 'local' and 'dev' whith dev being the shared deveopment environemtn and local logically isolcated my naming,

- **Promotion to Other Environments**: Deploy to staging or production using a **service principal** to maintain separation of duties:  
    dab deploy —workspace prod —env prod —token <service-principal-token>

### Supported Assets

DAB can deploy:

- **Notebooks** (Python, SQL, R, Scala)  
- **Libraries** (Python wheels, JARs, Maven dependencies)  
- **Jobs** (scheduled or triggered)  
- **Clusters** (interactive or job clusters)  
- **Secrets** (secret scopes and key-value pairs)  
- **Unity Catalog objects** (tables, schemas, catalogs, permissions)

### Best Practices

- Maintain **separate bundles or configuration files** for each environment.  
- Store bundles in **Git** for version control and auditability.  
- Integrate DAB deployments into CI/CD pipelines to automate testing and deployment.  
- Use **service principals** for production deployments rather than personal tokens.  
- Include **integration tests** to validate deployed assets.

—

## Git Integration

While DAB is ideal for production assets, notebooks, dashboards, and other interactive content are often managed through **Git integration**.  

- Connect a workspace to Git (GitHub, GitLab, Azure DevOps, Bitbucket).  
- Developers can work in branches and sync changes directly from the Databricks UI.  
- Provides **version tracking, collaboration, and code review workflows**.

—

## Databricks Connect

**Databricks Connect** allows IDEs (VSCode, PyCharm) to **execute code directly on remote Databricks clusters**.  

- Enables development in a familiar environment while leveraging Databricks compute.  
- Provides access to workspace resources, clusters, and installed libraries.  
- Speeds up development and testing of notebooks and code.

—

## Testing

Testing should cover unit, integration, and end-to-end scenarios.  

- Not all tests can be fully automated initially, but CI/CD pipelines should aim to run automated tests after deployments.  
- Testing ensures notebooks, jobs, and libraries behave consistently across environments.  
- Gradually building automated testing improves reliability and reduces errors in production deployments.