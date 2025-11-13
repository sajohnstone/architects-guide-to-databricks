# Chapter 3: Understanding Key Concepts

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

## Regions and networking

The question of region is fairly simple, pick a region that is close to where most of your processing is going to happen.  Check that Databricks features you need are supported in that region (not all are).  Try and avoid data going across regions as this can be expensive and slow.
Networking is a much more complex beast there are similarities between Azure and AWS but it defiantly helps to have someone with networking experiance at this stage.

### VPCs and Subnet

In most cases you want to create your own VNET or VPC for each workspace.  For reasons I don’t fully understand Databricks calls this VNET Injection in the Azure world but with AWS and GCP it’s called the slightly less impressive customer-managed VPC.  Naming aside you can let Databricks create a VNET/VPC for you this seems like less things to manage but in most organisations will want to set their own so that they can control routing to their own services.

With a VPC / VNet created you need to create the subnets.  Databricks needs two subnets for each workspace, you also probably want to have subnets for private links and reserve some for the future as changing subnets later is very difficult to do.

You also need to think about subnet sizing, at this early stage this can be difficult but try and ensure some growth.  Sizing isn’t super straight forward so check the latest Databricks documentation but essentially the calculation is

No of cluster x nodes - 4

This should give you the number of IPs you need in each subnet.  Once you have this you can add some reserved space and that gives you the CIDR block you need.  Note that on AWS you need subnets in each AZ so your total CIDR range needs to be 2 or 3 times bigger.
In case you are wondering why -4 it’s because AWS/GCP/Azure all reserve some IP space for things link DNS etc.

### PrivateLink

We can’t leave networking without talking about PrivateLink.  PrivateLink ensures that traffic between the two services uses private IPs inside the cloud provider network backbone, this make’s it more secure and is usually a requirement for large enterprises.  In most cases you want to setup the following private links.  

 - Backend PrivateLink: This goes from the Databricks Control Plane into your account and ensures and cloud API traffic is secure.
 - S3/Storage Account: This ensures that traffic going between your classic compute and storage is secure
 - NCC: Techncailly this isn’t PrivateLink you setup but that you setup from the Databricks Control Plane, but this secures traffic between Serverless and your storage (or other services)

### Data Ingress / Egress





	4.	Regions and networking
	5.	Cost planning: estimating and controlling costs
	6.	How to purchase Databricks licenses