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

A workspace is akin to an environment (not always the case) but each workspace has a unique url accoated with it.  A workspace acts of as a container for all of your work.

A **cluster** is the compute environment that executes your workloads. Clusters can be long-lived for interactive development or ephemeral for running jobs. The compute plane allows you to scale clusters according to your workload demands, balancing cost and performance.

**Notebooks** are the interactive interface where most development happens. They support multiple languages (Python, SQL, R, Scala) and allow you to mix code, documentation, and visualizations. While notebooks are excellent for experimentation, production workloads are typically run via jobs to ensure reliability and reproducibility.

---

## 2.3 Delta Lake Basics

Delta Lake underpins the reliability of the Databricks lakehouse. By sitting on top of object storage in the Data Plane, it brings **ACID transactions**, schema enforcement, time travel, and support for upserts and deletes to your data lake. 

This means your tables are consistent, historical versions of your data are accessible, and complex update patterns (like slowly changing dimensions) are easier to implement. Delta Lake effectively prevents the “data swamp” problem that often arises with unstructured data lakes.

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

---

## Summary

Understanding these core concepts is essential before you start planning your Databricks environment. You now know that:

- Databricks has three planes — Serverless Control, Classic Compute, and Data — each with specific responsibilities and ownership.  
- Workspaces, clusters, and notebooks are the foundation for day-to-day work.  
- Delta Lake provides reliability and consistency in the Data Plane.  
- Jobs and workflows operationalize your pipelines at scale.

With these fundamentals in place, you’re ready to start **planning your environment**, including workspace setup, storage, cost considerations, and CI/CD — topics we’ll cover in the next chapter.