# Chapter 3: Planning Your Databricks Deployment

—

## Introduction
I’ve been involved in fixing a few expensive mistakes in this phase.  Top expensive mistakes include
 - Deploying to a region that doesn’t support the features you need
 - Picking subnets that aren’t big enough to support your workloads
 - Not providing sufficient separation between environments
We will cover each of these areas and ensure you don’t fall into any traps

## Choosing a cloud: Azure, AWS, or GCP

In many cases, choosing a cloud is straightforward — often it will be the cloud your organization already uses. However, it’s important to understand some key differences.

The Databricks user experience is largely consistent across Azure, AWS, and GCP. The main differences come from cloud-specific integrations, pricing, and regional availability.

- **Azure:** Databricks is a first-tier service on Azure. Support is through Microsoft, and you get consolidated billing (one bill for DBU costs and virtual machines). Azure also provides tight integration with logging, monitoring, Entra, and other services.  

- **AWS:** Databricks integrates with AWS services like S3 and KMS. Compare the pricing on AWS as in my experiance it can be cheaper for similar workloads.

- **GCP:** Databricks on GCP integrates with services like BigQuery, Cloud Storage, and AI/ML tools. Features generally become available later on GCP and support is not as common.  I for instance have never implemented Databricks on GCP.

Other considerations include pricing differences between clouds and regions, networking and security requirements, and compliance or data residency rules. While the core Databricks experience is similar, these factors can influence the best choice for your organization.

—-

## Workspace setup and isolation strategy

From the previous chapter you should know what a workspace is.  The most common pattern for workspaces is to deploy one per environment e.g. dev, test, prod.  
With seperate workspaces is common practice to align these to cloud environments.  So assuming you had an Azure subscription for dev, test and prod you would split your workspaces over these subscriptions.
  
Before you can setup a workspace you need to have a Unity catalog metastore.  Your metastore stores information about tables, schema etc but not that actual data.  Databricks support one Metastore per account per region.  It is managed by Databricks so fully HA.  For BCDR you may want to consider another metastore in another region, but sharing a single metastore across an entire enterprise is common practice.  You can store your metadata in cloud storage or in the Databricks Control Plane.

Other patterns we see for workspaces are
 - per department per environment: In large enterprises for for example marketing-dev
 - infradev workspace: If using IaC (recommend) to deploy workspaces having somewhere to test these changes that isn’t the same as that environment your data engineers are using to develop can be beneficial.
 - Anayltics: Setting up a workspace with read-only access to production catalogs can provide a good way for users to access production data whilst keeping actual production as a break-glass only access.

A common mistake to avoid is having too many workspaces so that it becomes unmanageable I would avoid having project or workload specific workspaces.  Or having too few just lumping dev, test and prod into a single workspace is generally a bad idea.
 
## Storage architecture and considerations

A good starting point for storage architecture is to have a single catalog per workspace.  Within that catalog then have a seperate schema for each ingestion type so bronze_google_analytics, one for silver and one for gold.
This aligns with the medalian architecutre that Databricks advocates for but this is no no means the only option.  

Other patterns we see are:
 - Catalog per department: 
 - Central ‘gold’ catalog: 

Whichever way you decide to organise your catalogs and I would recommend starting simple and itterating how it’s stored is equally important.

Catalogs need a storage location a common and recomended pattern is to have a single S3 bucket or storage account per catalog.  You can use containers / folders within a storage account or bucket, but with very high throughput application you might start to hit the limits of the storage.  
In line with best practice storage account should be setup for least privilege and so the only access should be for the Databricks Control Plane and any breakglass required.
Storage redundancy is an interesting topic and links into BCDR which we will look at later, but it’s important to understand that replicating the data using cloud storage to another region is not a guaranteed solution.  Firstly whilst the data is replicated there is no easy way to rebuild a catalog so you would have to manually write scripts to do this.  Secondly delta lake writes data xxxxx.
Finally we need to think about xxx for storing data.  We can create a managed volume as part of a schema and then the data is stored in the same location as the catalog - great if you don’t need to access this data outside of databricks so for example checkpoints or libraries.
You can also add external locations and a common pattern we see here is to generate and **Input** and **output** external locations for each workspace.  These then make it easy for other applications to interact with Databricks is there is an obvious path for the data.

## Regions and Networking

### Choosing a Region

Selecting a region is usually straightforward — pick one that’s geographically close to where most of your data and processing will occur.  
Before deployment, **verify that the Databricks features you plan to use are available in that region**, since not all services (for example, serverless compute or Unity Catalog) are supported everywhere.

Avoid transferring large amounts of data across regions, as cross-region data egress can introduce both **latency** and **additional costs**.

—

## VPCs and Subnets

In most enterprise deployments, it’s best to **create and manage your own network** rather than letting Databricks provision it automatically.

- **Azure:** This is called **VNet Injection**, where the Databricks workspace is deployed into a user-managed Azure Virtual Network (VNet).  
- **AWS:** The same concept is referred to as a **Customer-Managed VPC**.  
- **GCP:** Uses a **Customer-Managed VPC** model as well, though “VPC injection” is not a term typically used.

Letting Databricks create the VNet or VPC for you may simplify initial setup, but most organizations prefer to control their own networking to manage **routing, peering, security policies, and private connectivity to other services**.

### Subnets

Each Databricks workspace requires **two dedicated subnets**:

- One for **host (public)** network interfaces.
- One for **container (private)** network interfaces.

You should also plan for **additional subnets** for:

- **PrivateLink connections** (for secure data plane traffic).  
- **Future expansion**, since changing subnet ranges after deployment is difficult or unsupported.

### Subnet Sizing

Subnet sizing depends on the number of nodes that will run in your Databricks clusters. As a rough guideline:

```
Required IPs ≈ (Number of clusters × Average nodes per cluster) + Reserved IPs
```

Each cloud provider reserves a few IP addresses per subnet:

- **Azure:** 5 IPs reserved  
- **AWS:** 5 IPs reserved  
- **GCP:** 4 IPs reserved  

If you expect growth, allocate extra space when defining CIDR ranges.

On **AWS**, each subnet must exist in a different **Availability Zone (AZ)**, so plan for at least two subnets — typically doubling or tripling your overall CIDR allocation depending on your high-availability setup.

—

## PrivateLink and Secure Connectivity

**PrivateLink** (AWS and Azure) or **Private Service Connect** (GCP) ensures that network traffic between Databricks components and your services stays **within the cloud provider’s private network backbone**, never traversing the public internet.

This is typically a **requirement for enterprise deployments** to enhance security and simplify compliance.

Common PrivateLink configurations include:

- **Backend PrivateLink**  
  Connects the Databricks **control plane** (managed by Databricks) to your **data plane** (your VPC/VNet).  
  Ensures control plane API and management traffic are secured via private IPs.

- **Storage PrivateLink**  
  Connects your Databricks clusters or serverless compute to your **object storage** (e.g., AWS S3, Azure Storage Account, or GCP Cloud Storage).  
  Prevents data traffic from leaving the internal cloud network.

- **UCC (Unity Catalog Connectivity)**  
  Databricks uses **Unity Catalog Connectivity (UCC)** — a managed private endpoint from the **serverless control plane** to your data sources (e.g., S3, ADLS, or BigQuery).  
  This is not a PrivateLink you configure manually; instead, it’s managed by Databricks to secure **Serverless and Unity Catalog traffic** to your resources.

—

## Data Ingress and Egress

Managing **data ingress and egress** ensures that traffic to and from your Databricks workspace is **secure, controlled, and compliant** with enterprise policies.

Common patterns include:

- **Front-End PrivateLink**  
  Provides a **private IP** for accessing your Databricks workspace.  
  Once configured, you can **block public access**, making the workspace accessible **only from your VNET/VPC**.  

- **Access Control Lists (ACLs)**  
  Can be applied to restrict which **IP ranges** can access your workspace.  Easier to setup than Frontend PrivateLink but can be difficult to manage all those IPs.

- **Controlling Outbound Access**  
  Outbound internet access from workspaces can be restricted using standard VPC/Vnet controls.  Be aware that doing this will impact installing libraries so another approach Will be needed like connecting to a private .


## Cost planning: estimating and controlling costs

Predicting consumption can be difficult during the planning stage.  You will need to estimate what workloads you will need across your environments and then use the Databricks pricing calculators to help you.
It’s worth noting that there are three major costs involved
- DBT Cost: Calculated per xx this is the cost Databricks charges for using its services.
- Compute Cost: If using the classic compute plane this is the cost of the VM and EC2 that run the clusters
- Data Ingress / Egress: In many cases the lesser of the three but if you are transferring large files especially cross region these costs can add up
Having estimated your costs once you have deployed your development environment and are able to run some PoC workloads you can refine in based on the actual costs.  At each stage of the roll out you should be able to get more production-like data to be able to refine.

### Controlling costs

At the planning stage there are some key controls you can add to ensure that your spend doesn’t exceed your budgets
- Cost dashboard: this can be deployed from the Account Console and gives you a good overall view of where costs are going at a workspace level.  Use this to focus your energy on the key areas.
- Budgets: In AWS this can be setup in the Account console on Azure you can do it in xxx.  Use this to send out alerts when you are going to exceed your budget
- Sizing: There is some trial and error in right sizing so a smaller cluster is not always cheaper as it can take longer and threfor cost more than a larger quicker cluster, but I would still recommend starting small and working up.
- Cluster Policies: You can use Cluster policies to ensure that clusters are being provisioned with the right size and settings.  A common example is to enforce and auto termination or to ensure no one can create a XXL cluster for running their hello world application. 

## How to purchase Databricks

It’s a common question I get asked but the answer is rather simple.  You can purchase Databricks using the following methods
 - Azure console
 - AWS Marketplace
 - Databricks direct
In all cases it will redirect back to the Databricks account team and in many cases you will get an Account Manager who can help you.  Each Account Manager has one or more RSA Resident Solution Architect who can help you with many of the technical aspects of Databricks.  