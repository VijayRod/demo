```
Software Engineering
│
├── Software Architecture
│   ├── Architectural Patterns
│   │   ├── MVC / MVVM
│   │   ├── Clean Architecture
│   │   ├── Hexagonal / Onion
│   │   └── Event-Driven Architecture
│   └── Application Layers
│       ├── Presentation Layer (UI)
│       ├── Business Logic Layer
│       └── Data Access Layer
│           └── ORM (Entity Framework, Dapper, NHibernate, ADO.NET)

├── Frontend Technologies
│   ├── React / Next.js
│   ├── Tailwind CSS
│   ├── Zustand / Redux Toolkit
│   └── WebSockets / Socket.IO

├── Backend Technologies
│   ├── Node.js / NestJS
│   ├── Go
│   ├── ASP.NET Core / C#
│   ├── REST / GraphQL
│   └── Messaging (Kafka, NATS, Redis PubSub)

├── Infrastructure & Observability
│   ├── Kubernetes (AKS)
│   ├── Autoscaling (KEDA / HPA / VPA)
│   ├── GitOps (ArgoCD / Flux)
│   ├── Terraform / Helm Charts
│   └── Observability
│       ├── Prometheus (metrics collection)
│       ├── Grafana (dashboards, alerts)
│       ├── eBPF (kernel-level observability)
│       │   ├── Cilium / Tetragon / BPFTrace / BCC
│       │   └── Falco (runtime security)
│       ├── Loki / Alertmanager
│       ├── OpenTelemetry (unified tracing)
│       ├── Distributed Profiling (Parca, Pyroscope)
│       └── Linux OOM Killer
│           ├── dmesg / kernel logs
│           ├── oom_score_adj tuning
│           └── K8s Memory Eviction Policies

├── Software Design
│   ├── Design Patterns
│   │   ├── Creational (Factory, Singleton, Builder)
│   │   ├── Structural (Adapter, Decorator, Composite)
│   │   └── Behavioral (Strategy, Observer, Command)
│   └── SOLID Principles / OOP

├── Quality & Maintainability
│   ├── Testing (Unit, Integration)
│   │   ├── xUnit / NUnit
│   │   └── Moq
│   ├── Refactoring
│   └── Code Reviews / Linting / Static Analysis
│       ├── StyleCop
│       ├── SonarQube
│       └── ReSharper

├── Software Lifecycle & Process
│   ├── CI/CD (Continuous Integration / Delivery)
│   ├── DevOps Practices
│   ├── Documentation & Modeling (UML, Diagrams)
│   └── Twelve-Factor App Principles

├── Core Technologies
│   ├── Data Persistence
│   │   ├── SQL Server / NoSQL / Schema Design
│   │   ├── Indexing / Query Plans / Caching
│   │   ├── Search Structures (Full-text, Trie)
│   │   ├── ACID Transactions
│   │   ├── Write-Ahead Logging (WAL)
│   │   └── Replication (Leader-Follower, Multi-Leader, Geo)
│   ├── API & Testing Tools
│   │   ├── REST / JWT / OAuth2
│   │   ├── Swagger / Postman / Fiddler
│   │   └── Contract Testing (Pact, Dredd)
│   ├── Code Quality & Version Control
│   │   ├── GitHub / GitLab / Azure Repos
│   │   ├── Git Flow / Trunk-Based Development
│   │   └── Commit Signing (GPG / SSH)
│   └── Reporting & Analytics
│       ├── Grafana Panels / Power BI
│       ├── SQL Reporting / ETL / SSRS
│       └── KPIs / SLAs / SLOs

├── AI/ML & Intelligent Automation
│   ├── LLMs (OpenAI GPT, LLaMA, Mistral)
│   ├── MLOps (MLFlow, Kubeflow, Azure ML)
│   ├── Inference (ONNX, TensorRT)
│   ├── Feature Stores (Feast)
│   └── Vector Embeddings & Semantic Search

├── Edge Computing & Serverless
│   ├── Cloudflare Workers / Vercel Edge Functions
│   ├── AWS Lambda / Azure Functions
│   ├── WebAssembly (WASM)
│   └── Lightweight Runtimes (Spin, Slang)

├── Data Streaming & Realtime Systems
│   ├── Apache Flink / Spark Streaming
│   ├── Apache Pinot / Druid
│   ├── Change Data Capture (Debezium + Kafka)
│   └── Temporal.io / Cadence

├── Distributed Systems
│   ├── Principles
│   │   ├── CAP Theorem / PACELC
│   │   ├── Consistency Models (Strong, Eventual, Causal)
│   │   ├── Replication (Sync, Async, Quorum, Geo)
│   │   ├── ACID / WAL
│   │   └── Split-Brain Handling
│   │       ├── Quorum / STONITH / Fencing
│   │       └── Failover Strategies (etcd, Consul, ZooKeeper)
│   ├── Coordination & State
│   │   ├── Leader Election / Raft / Paxos
│   │   ├── Service Discovery (etcd, Consul)
│   │   └── CRDTs / Event Stores / Gossip Protocols
│   ├── Fault Tolerance
│   │   ├── Circuit Breakers / Retries / Backoff
│   │   └── Chaos Engineering / Degradation Handling
│   └── Observability
│       ├── Prometheus Exporters
│       ├── Grafana Dashboards
│       ├── eBPF for Deep Tracing and Network Telemetry
│       └── Linux OOM Kill Metrics

├── Cloud & Infrastructure Systems
│   ├── Identity & Security
│   │   ├── IAM (Azure AD, AWS IAM, GCP IAM)
│   │   ├── RBAC / OAuth2 / OIDC / SAML
│   │   ├── Zero Trust / SPIFFE / SPIRE / OPA
│   │   └── Vault / KMS / HSM / Sealed Secrets
│   ├── Networking
│   │   ├── VPC / VNet / Subnetting / IPAM
│   │   ├── Load Balancers / WAF / Service Mesh
│   │   └── Cilium + eBPF
│   ├── Compute & Virtualization
│   │   ├── VMs / Containers / Serverless
│   │   ├── Hypervisors / Node Pools / Affinity Rules
│   │   ├── GPU Scheduling / NUMA / CPU Pinning
│   │   └── Linux OOM Killer Behaviour and Tuning
│   ├── Storage Systems
│   │   ├── SSD / NVMe / Block / Object / File
│   │   ├── Tiered / Encrypted / Snapshots / Backups
│   │   └── Replication / WAL / Durability
│   ├── Zones, Regions & High Availability
│   │   ├── Availability Zones / Multi-Region
│   │   ├── Load Balancing / Disaster Recovery
│   │   └── Split-Brain Awareness / Quorum Voting
│   ├── Energy & Sustainability
│   │   ├── GreenOps / Carbon-Aware Scheduling
│   │   ├── PUE / Cooling Efficiency / Renewable Energy
│   │   └── Lifecycle Optimization / Hardware Recycling
│   └── Hardware & Acceleration
│       ├── CPU Architectures (x86_64, ARM64)
│       ├── GPU (NVIDIA A100, H100, Grace Hopper)
│       ├── TPUs / IPUs / FPGAs
│       └── Memory Optimisation (HugePages, NUMA, RDMA)

└── Operating System Kernel
    ├── Linux Kernel Interfaces (syscalls, procfs, cgroups)
    ├── Process Scheduler / CFS
    ├── Memory Management (Page Cache, Swapping, OOM Killer)
    ├── Networking Stack (Netfilter, TCP/IP)
    ├── Filesystems (ext4, xfs, overlayfs)
    ├── Namespaces and Isolation (user, net, pid)
    └── Tracing & Profiling (eBPF, perf, ftrace)

```
