# Chapter 2: Understanding Key Concepts

---

## Introduction

Before diving into building on Databricks, it’s important to understand the platform at a conceptual level. This chapter introduces the fundamental pieces that make up Databricks and explains how they fit together so you can design, operate, and scale your lakehouse effectively.

We’ll cover the platform architecture, the basic building blocks like workspaces and clusters, Delta Lake essentials, and how jobs and workflows drive operational pipelines.

---

## 2.1 Databricks Architecture Overview

Databricks differs from a traditional database because it separates compute and storage. Your data lives in cloud object storage such as S3 or ADLS, while compute resources are provisioned on demand to process that data. You only pay for compute while it’s running, which allows for elastic scaling and efficient cost management.

Databricks is organised around three planes, each representing a different layer of responsibility and ownership within the platform. When we talk about a “plane,” we’re really referring to the cloud accounts or subscriptions that Databricks operates as part of the service.

The Control Plane is where the Databricks user interface and APIs live — it’s what you interact with when using the platform. Under the hood, the Control Plane uses the cloud provider’s APIs (AWS, Azure, or GCP) to create and manage the virtual machines that execute your Spark, Python, and SQL workloads.

The Classic Compute Plane is where those compute resources actually run. When Databricks provisions a cluster, it does so inside your cloud account. Because the resources live in your account, they inherit your networking configuration, including any VNet, subnet, or security settings you’ve defined.

The Serverless Control Plane works in a similar way to the Classic Compute Plane, except that the compute runs inside Databricks-managed accounts instead of yours. This difference becomes important when understanding networking and connectivity — and it also affects cost, as Databricks fully manages and bills for these serverless resources.

Note: The Classic Compute Plane has evolved in name over time — it was once called the Data Plane and later the Compute Plane. You might still see those terms in older documentation, so it’s useful to know they all refer to the same concept.

![Databricks Architecture](./images/databricks-architecture.png)

---

## 2.2 Workspaces, Clusters, and Notebooks

A **workspace** is akin to an environment (but not always the case) but each workspace has a unique url accoated with it.  A workspace acts of as a container for all of your work so things like clusters, jobs and notebooks are all associated with a workspace.

A **cluster** is the compute environment that executes your workloads. Clusters can be long-lived for interactive development or ephemeral for running jobs. Compute can be serverless e.g. running in the Serverless Control Plane on in your own environment using the Classic Compute Plane.  Clusters according to your workload demands, balancing cost and performance.

**Notebooks** are the interactive interface where most development happens. They support multiple languages (Python, SQL, R, Scala) and allow you to mix code, documentation, and visualizations.

We will talk about plenty of other concepts but if you understand this and a bit about how data is organised you will understand the fundaments.


---

## 2.3 Storage Basics

**Catalogs** are the top level storage container in Databricks so when we are referring to data we typically go catalog.schema.table.  Within a catalog you can store structured data in tables and unstructured data in managed volumes.  Databricks has the concept of managed and unmanaged tables, managed tables are stored in Deltalake format operate more like a typical data warehouse.  Unmanaged tables leaves the data where it is, but still allows you to perform SQL and Spark queries over it.

Delta Lake format is based on Parquet — when you create a managed table, it stores the table’s rows as Parquet files. How these files are stored and managed is controlled by the Delta Lake library, which also writes a transaction log (stored in the _delta_log folder) that enables time travel and ACID transactions.

---



## 2.4 Jobs and Workflows

Jobs are how Databricks operationalizes pipelines. A job can run a notebook, a JAR, a Python script, or a SQL query on a schedule or triggered by an event. Workflows allow you to chain jobs together, define dependencies, and handle retries, ensuring that your pipelines run reliably without manual intervention.

With jobs and workflows, you can move from exploratory notebooks to production-grade pipelines, enabling repeatable, auditable processes across your data platform.

---

## 2.5 Account Access and Data Access

How access control works is something that we will cover in a later chapter but it's worth noting early that there a things you control at the following levels
- Account: There are a few controls which happen at account level one example is xxxx
- Workspace: Controls such as compute policy, xxxx all happen at workspace level
- Data: Data level access is applied across all workspaces and covers catalog, schema and table permissions.

## 2.6 Unity Catalog

Unity Catalog stores permissions related to your data.  It works across all workspaces so if I grant access to a Catalog (and it’s attached to two workspaces) I will have access to it in both.  Unity Catalog also has some supporting functions like data linage and stores audits.

---

## Summary

Understanding these core concepts is essential before you start planning your Databricks environment. You now know that:

- Databricks has three planes — Serverless Control, Classic Compute, and Data — each with specific responsibilities and ownership.  
- Workspaces, clusters, and notebooks are the foundation for day-to-day work.  
- Delta Lake provides reliability and consistency in the Data Plane.  
- Jobs and workflows operationalize your pipelines at scale.

With these fundamentals in place, you’re ready to start **planning your environment**, including workspace setup, storage, cost considerations, and CI/CD — topics we’ll cover in the next chapter.