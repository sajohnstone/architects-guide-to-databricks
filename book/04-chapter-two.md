# Chapter 2: Understanding Key Concepts

—

## Introduction

Before diving into building on Databricks, it’s important to understand the platform at a conceptual level. This chapter introduces the fundamental components that make up Databricks and explains how they fit together so you can design, operate, and scale your lakehouse effectively.

We’ll cover the platform architecture, the basic building blocks like workspaces and clusters, Delta Lake essentials, and how jobs and workflows drive operational pipelines.

—

## 2.1 Databricks Architecture Overview

Databricks differs from a traditional database because it separates **compute** and **storage**. Your data lives in cloud object storage such as **S3** or **ADLS**, while compute resources are provisioned on demand to process that data. You only pay for compute while it’s running, which allows for elastic scaling and efficient cost management.

Databricks is organised around **three planes**, each representing a different layer of responsibility and ownership within the platform. When we talk about a “plane,” we’re referring to the cloud accounts or subscriptions that Databricks operates as part of the service.

The **Control Plane** is where the Databricks user interface and APIs live — it’s what you interact with when using the platform. Under the hood, the Control Plane uses the cloud provider’s APIs (AWS, Azure, or GCP) to create and manage the virtual machines that execute your Spark, Python, and SQL workloads.

The **Classic Compute Plane** is where those compute resources actually run. When Databricks provisions a cluster, it does so inside your cloud account. Because the resources live in your account, they inherit your networking configuration, including any VNet, subnet, or security settings you’ve defined.

The **Serverless Compute Plane** works in a similar way to the Classic Compute Plane, except that the compute runs inside Databricks-managed accounts instead of yours. This difference becomes important when understanding networking and connectivity — and it also affects cost, as Databricks fully manages and bills for these serverless resources.

> **Note:** The Classic Compute Plane has evolved in name over time — it was once called the **Data Plane** and later the **Compute Plane**. You might still see those terms in older documentation, so it’s useful to know they all refer to the same concept.

![Databricks Architecture](./images/databricks-architecture.png)

—

## 2.2 Workspaces, Clusters, and Notebooks

A **workspace** is like an environment, with its own unique URL. It acts as a container for all your work — clusters, jobs, notebooks, and other assets all belong to a specific workspace.

A **cluster** is the compute environment that executes your workloads. Clusters can be long-lived for interactive development or short-lived for running jobs. Compute can be **serverless** (running in the Serverless Compute Plane) or **classic** (running in your own cloud account). Clusters scale according to workload demands, balancing cost and performance.

**Notebooks** are the interactive interface where most development happens. They support multiple languages (Python, SQL, R, and Scala) and allow you to mix code, documentation, and visualizations in a single place.

We’ll cover more advanced concepts later, but if you understand these core building blocks — and how data is organised — you already grasp the fundamentals.

—

## 2.3 Storage Basics

**Catalogs** are the top-level storage containers in Databricks, so when we refer to data we typically use the format **catalog.schema.table**. Within a catalog you can store structured data in **tables** and unstructured data in **managed volumes**.  

Databricks has the concept of **managed** and **unmanaged** tables:  
- **Managed tables** are stored in **Delta Lake format** and operate more like a traditional data warehouse.  
- **Unmanaged tables** leave the data in its existing location but still allow you to perform SQL and Spark queries over it.

Delta Lake format is based on **Parquet** — when you create a managed table, it stores the table’s rows as Parquet files. How these files are stored and managed is controlled by the **Delta Lake library**, which also writes a **transaction log** (stored in the `_delta_log` folder) that enables **time travel** and **ACID transactions**.

—

## 2.4 Jobs and Workflows

**Jobs** are how Databricks operationalizes pipelines. A job can run a notebook, JAR, Python script, or SQL query on a schedule or in response to an event.  

**Workflows** allow you to chain jobs together, define dependencies, and handle retries — ensuring that your pipelines run reliably without manual intervention.

With jobs and workflows, you can move from exploratory notebooks to production-grade pipelines, enabling repeatable and auditable processes across your data platform.

—

## 2.5 Account Access and Data Access

Access control operates at several levels within Databricks:

- **Account level:** Includes global configurations like identity federation, Unity Catalog metastore assignment, and account admin roles.  
- **Workspace level:** Covers settings such as cluster policies, job permissions, and workspace object access (notebooks, folders, repos).  
- **Data level:** Managed through **Unity Catalog**, which enforces permissions across all workspaces for catalogs, schemas, and tables.

We’ll explore these in more detail later, but it’s important to recognise that data permissions and workspace permissions are managed separately.

—

## 2.6 Unity Catalog

**Unity Catalog** is the unified governance layer in Databricks that provides centralised management of data permissions, metadata, and lineage across all workspaces. It controls who can access which catalogs, schemas, and tables, while maintaining consistent auditing and security policies.  

Unity Catalog does **not** manage workspace-level permissions like cluster policies or notebook access — those remain within each workspace.

There was a time when Databricks didn’t have Unity Catalog so in the documentation you will see references to none unity catalog enabled workspaces.  For the remainder of this book we are assuming you are using Unity Catalog (there is no good reason not to) but you might see it in other documentation.

—

## Summary

Understanding these core concepts is essential before you start planning your Databricks environment. You now know that:

- Databricks has **planes** — Control Plane, Serverless and Classic Compute — each with specific responsibilities and ownership.  
- **Workspaces, clusters, and notebooks** are the foundation for day-to-day work.  
- **Catalogs** Store your data in the form of tables (managed and unmanaged) and volumes.  
- **Jobs and workflows** All you to run operational pipelines.
- **Unity Catalog** Provides permissions to your Catalogs, schemas and tables.

With these fundamentals in place, you’re ready to start **planning your environment**, including workspace setup, storage configuration, cost management, and CI/CD — topics we’ll cover in the next chapter.

—-