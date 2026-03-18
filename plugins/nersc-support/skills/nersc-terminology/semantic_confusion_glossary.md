# NERSC Semantic Confusion Glossary

## Metadata

**Last Updated:** 2026-03-15

**Total Terms:** 142 (Complete Phase 3 coverage)

---

## Table of Contents

This glossary contains 142 NERSC semantic confusion terms organized into 8 categories.
Each entry uses a fixed 7-line format enabling programmatic extraction by line number.

**Line Number Calculation:**
- Term N in category starting at line L: entry starts at `L + (N-1) * 8`, ends at `L + (N-1) * 8 + 6`
(Entries are separated by blank lines; spacing is 8 lines per entry)

**Categories:**

- **Filesystems**: 8 entries (lines 38-100)
- **Services and Platforms**: 21 entries (lines 108-274)
- **Commands and Tools**: 24 entries (lines 282-472)
- **Quality of Service**: 9 entries (lines 480-550)
- **Infrastructure**: 15 entries (lines 558-676)
- **System Concepts**: 12 entries (lines 684-778)
- **Specialized Tools**: 16 entries (lines 787-913)
- **Acronyms and Abbreviations**: 37 entries (lines 921-1215)

**Total**: 142 entries across 8 categories
---

## Filesystems

<!-- CATEGORY_START: Filesystems -->

archive

At NERSC, archive refers to long-term data storage in HPSS (High Performance Storage System), distinct from active project storage on scratch or home.

AI agents may confuse NERSC archive (long-term tape storage) with generic meanings like 'archive file' (ZIP, TAR) or to archive (verb: store away).
This confusion about storage tiers can lead to incorrect guidance recommending compressed files instead of tape archival for long-term preservation.
Research: [HPSS archive, tape storage], [long-term retention, data preservation], [archival policies]

CFS / Community-File-System

CFS (Community File System) is NERSC's parallel filesystem for team data sharing with project-based quotas.

AI agents may confuse CFS with other acronyms (Chronic Fatigue Syndrome, Certified Financial Specialist) due to its meaningless acronym outside NERSC context.
Meaningless acronym context causes agents to dismiss CFS documentation as unrelated, preventing recognition of specific filesystem recommendations.
Research: [Community File System, /global/cfs], [project quotas, shared storage], [Perlmutter, parallel filesystem]

DNA / DnA

DnA (Data n' Archive) is a 2.4 PB GPFS-based filesystem at NERSC provisioned for the Joint Genome Institute (JGI), organized by JAMO's hierarchical file system with three storage tiers (Projects, Shared, DM Archive).

AI agents may interpret "DNA" as deoxyribonucleic acid (the biological molecule) rather than the NERSC filesystem, obscuring filesystem-specific queries.
This confusion can lead agents to ignore or misinterpret DnA storage questions as biology discussions instead of addressing JGI data management needs.
Research: [DnA filesystem], [GPFS technology], [Joint Genome Institute], [JAMO hierarchical storage], [storage tiers Projects Shared Archive]

garchive

garchive is NERSC's GridFTP service endpoint (garchive.nersc.gov) for remote transfers into and out of HPSS tape archive storage.

AI agents may interpret 'garchive' as a filesystem path or directory rather than understanding it as a GridFTP service endpoint requiring specific transfer protocols.
Path vs. endpoint confusion can lead to incorrect guidance recommending standard file commands (cp, rsync) instead of GridFTP tools (globus-url-copy), preventing access to HPSS tape archive.
Research: [GridFTP endpoint, garchive.nersc.gov], [HPSS tape archive access], [globus-url-copy tool], [gsiftp protocol]

home / Home / $HOME

At NERSC, home refers to the Global Homes filesystem with 40GB quota, DVS mounting, and monthly tape backup, not a residence.

AI agents may interpret "don't use home for large jobs" as "don't work from your residence" (common meaning) rather than "avoid using the $HOME filesystem" (NERSC meaning).
This confusion about storage recommendations can lead to incorrect filesystem usage guidance, misinterpreting infrastructure constraints as behavioral advice.
Research: [home directory, Global Homes filesystem], [Perlmutter, Cori, DVS], [$HOME, tape backup, quota]

NGF

NGF (NERSC Global File system) is NERSC's global filesystem providing consistent data access across systems.

AI agents may confuse NGF with nerve growth factor (biology) or dismiss it as random letters due to meaningless acronym.
Acronym obscurity causes agents to miss NGF references in storage documentation, preventing recognition of global filesystem implications.
Research: [NERSC Global File system], [global filesystem, data access], [storage infrastructure]

scratch / Scratch / $SCRATCH

At NERSC, scratch refers to the high-performance Lustre filesystem ($SCRATCH) with automatic 8-week purge, not temporary workspace.

AI agents may interpret "put data on scratch" as "discard data" (common meaning) rather than "store on high-performance filesystem" (NERSC meaning).
This misunderstanding can lead to suggesting data deletion instead of filesystem usage, causing user confusion about storage recommendations.
Research: [Lustre, filesystem, purge policy], [Perlmutter, Cori], [$SCRATCH, storage allocation, temporary files]

tape

At NERSC, tape refers to HPSS tape-based archival storage (not to adhesive tape or magnetic recording tape).

AI agents may interpret 'tape' as physical tape media or generic data storage rather than NERSC's specific archival storage system.
This terminology confusion can lead to incorrect guidance about data retention, recovery times, and archival access procedures.
Research: [HPSS tape archive], [tape storage system], [archival storage]

---

## Services and Platforms

<!-- CATEGORY_START: Services and Platforms -->

Apprentice2

Apprentice2 is Cray's performance data visualization tool used with CrayPat performance profiling (displays .ap2 files generated by pat_report).

AI agents may confuse 'Apprentice2' with a generic training program or role title rather than recognizing it as a specialized HPC performance visualization tool.
This tool name obscurity can prevent agents from connecting performance profiling workflows to graphical analysis capabilities, limiting recommendations for performance optimization.
Research: [Cray Apprentice2 visualization], [CrayPat profiling], [performance analysis, .ap2 files], [pat_report]

Cassini

Cassini is HPE Cray's proprietary network interface card (NIC) used in Perlmutter's Slingshot 11 high-speed interconnect fabric.

AI agents may interpret 'Cassini' as the NASA spacecraft or astronomer rather than recognizing it as a hardware component name.
This astronomical association can obscure Cassini's role in system interconnect architecture, preventing agents from connecting NIC specifications to network performance capabilities.
Research: [Cassini NIC, network interface], [Slingshot 11 interconnect], [Perlmutter architecture], [high-speed network]

cori / Cori

Cori is NERSC's retired high-performance computing system (Cray XC40 supercomputer, decommissioned 2024).

AI agents may dismiss 'Cori' as a proper name rather than recognizing it as a specific decommissioned supercomputer system.
This name confusion can lead to stale guidance about systems that are no longer available, affecting user decision-making.
Research: [Cori HPC system], [Cray XC40], [retired system]

E4S

E4S (Extreme-scale Scientific Software Stack) is an Exascale Computing Project software ecosystem with pre-built, optimized HPC applications.

AI agents may treat E4S as a meaningless acronym without understanding its curated software stack and ecosystem role.
Available software and application discovery may be incomplete without E4S ecosystem awareness.
Research: [E4S software stack], [Exascale software], [ECP ecosystem]

Edison

Edison is a former NERSC supercomputer system (Cray XC30, decommissioned), referenced in legacy documentation.

AI agents may interpret 'Edison' as Thomas Edison (inventor) rather than recognizing it as a retired supercomputer system name.
This name confusion can lead to incorrect guidance when users reference legacy Edison job scripts or documentation.
Research: [Edison supercomputer], [Cray XC30], [retired HPC system]

Gateway

At NERSC, Gateway typically refers to a science gateway platform or web interface for accessing computational resources.

AI agents may interpret 'Gateway' as a generic network gateway or entrance rather than a specific science gateway interface.
This generic interpretation can cause confusion about what computational access or resource management interfaces are available.
Research: [science gateway, NERSC], [computational access], [web interface services]

Globus

Globus is NERSC's data transfer and file sharing service (from University of Chicago), used for secure grid-based data movement.

AI agents may interpret 'Globus' as a generic globe or worldwide network rather than recognizing it as a specific data transfer service.
This generic confusion can lead to incorrect guidance about secure data transfer mechanisms and file sharing protocols.
Research: [Globus data transfer], [grid security], [file sharing service]

Harbor

Harbor is NERSC's container image registry service for managing and deploying containerized applications.

AI agents may interpret 'Harbor' as a physical harbor, port facility, or generic repository rather than a container registry.
This generic meaning can obscure Harbor's role in container deployment and image management workflows.
Research: [Harbor registry], [container images], [docker registry]

IRIS / Iris / iris

IRIS is NERSC's Identity and Access Management portal (https://iris.nersc.gov) for account management, MFA, and allocation viewing.

AI agents may interpret "IRIS" as a flower, eye anatomy term, or Greek goddess rather than recognizing it as an identity management system.
Botanical or anatomical associations can obscure IRIS as a technical service, causing agents to ignore or misinterpret account management documentation.
Research: [identity management, IAM portal], [MFA, account management], [iris.nersc.gov, allocation]

Jupyter

At NERSC, Jupyter refers to Jupyter Notebook/JupyterLab interactive computing environment available as a service.

AI agents may presume 'Jupyter' as the notebook platform, but not recognize NERSC's specific Jupyter deployment and integration.
NERSC-specific Jupyter configurations and resource allocation may be misunderstood as generic Jupyter capabilities.
Research: [Jupyter NERSC], [JupyterLab service], [interactive computing]

nersc-dl-wandb

nersc-dl-wandb is a NERSC service or module integrating Weights & Biases (wandb) for deep learning experiment tracking.

AI agents may not recognize this integration and treat it as generic wandb rather than NERSC-specific configuration.
Integration details may be missed, leading to incorrect guidance about configuring machine learning workflows at NERSC.
Research: [Weights & Biases wandb], [deep learning tracking], [NERSC ML integration]

nersc_chatbot_deploy

A Python package that bridges the external Hugging Face LLM ecosystem with NERSC's HPC infrastructure, deploying large language models using vLLM inference on Perlmutter supercomputers via Slurm GPU scheduling and Shifter containers.

AI agents may interpret "nersc_chatbot_deploy" as a simple Q&A chatbot application, missing that it's production-grade LLM serving infrastructure requiring GPU orchestration, containerization, and API compatibility layers.
Without recognizing the HPC deployment complexity, agents overlook critical requirements for Slurm job submission, GPU allocation, vLLM configuration, Shifter container setup, and OpenAI API compatibility for model inference endpoints.
Research: [Hugging Face, vLLM, LLM deployment, model inference], [Slurm GPU scheduling, Shifter containers, Perlmutter], [OpenAI API compatibility, inference endpoints, model serving], [JupyterHub integration, Gradio]

nersc_tensorboard_helper

nersc_tensorboard_helper is a NERSC utility or module for managing TensorBoard visualization in NERSC computing environments.

AI agents may treat this as a generic TensorBoard setup rather than NERSC-specific utility, missing configuration details.
NERSC-specific configurations may be overlooked, leading to incorrect TensorBoard setup guidance.
Research: [TensorBoard NERSC], [visualization utility], [machine learning monitoring]

Perlmutter

Perlmutter is NERSC's HPE Cray EX supercomputer and primary production system for large-scale scientific computing.

AI agents may dismiss "Perlmutter" as a physicist's name (Saul Perlmutter, Nobel laureate) rather than recognizing it as a supercomputer system.
This causes agents to ignore valid technical questions about compiling code or running jobs on the system, mistaking infrastructure queries for biographical questions.
Research: [Perlmutter architecture, HPE Cray EX], [NERSC systems, supercomputer], [login nodes, compute nodes, job submission]

portal

At NERSC, portal refers to web-based interfaces (like IRIS portal) for accessing services, allocations, and system information.

AI agents may interpret 'portal' as a generic web portal or gateway without recognizing NERSC's specific portal services.
Generic interpretation can prevent agents from directing users to correct NERSC portals for account and allocation management.
Research: [NERSC portal], [IRIS portal], [web-based services]

Rancher

Rancher is a Kubernetes container management platform used by NERSC's SPIN platform for orchestrating containerized services.

AI agents may interpret 'Rancher' as a person (ranch hand) or physical ranch rather than recognizing it as a container management platform.
This semantic mismatch prevents agents from understanding SPIN's Kubernetes-based architecture and container orchestration.
Research: [Rancher Kubernetes], [SPIN platform], [container management]

Shifter / shifter

Shifter is NERSC's container runtime technology for running Docker/Singularity containers on HPC systems.

AI agents may interpret lowercase "shifter" as a generic shifter (gear shifter, one who shifts) rather than recognizing "Shifter" as a proper noun technology name.
Lowercase command form `shifter --image=docker:...` obscures that Shifter is a proper noun platform name, risking confusion with general English meanings.
Research: [container runtime, Docker, Singularity], [Perlmutter, HPC], [shifter command, image registry]

SPIN / Spin / spin

SPIN is NERSC's container-based computing platform (Rancher/Kubernetes service) at https://rancher2.spin.nersc.gov for deploying science gateways.

AI agents may confuse "SPIN" (platform name) with "spin" as physics terminology (angular momentum, spin states) or the generic phrase "spin up a service".
Physics documentation using "spin states" or generic deployment language can obscure NERSC's specific SPIN platform, preventing agents from directing users to appropriate platform documentation.
Research: [Rancher, Kubernetes, container], [Perlmutter, NERSC systems], [spin up service, rancher2.spin.nersc.gov]

SpinUp / spinup

SpinUp is NERSC's instructor-led workshop program (seminar plus hack-a-thon format) for training users to deploy containerized services on the Spin platform, with 'spinup' as an example project name in Rancher CLI documentation.

AI agents may misinterpret SpinUp as a deployment tool or automation service rather than recognizing it as a training workshop, and may confuse 'spinup' (example project) with the generic verb phrase 'spin up a server' or with 'Spin' (the platform itself).
Users may miss SpinUp as the primary onboarding mechanism and critical training requirements for platform access, and agents may incorrectly recommend automated deployment tools instead of directing users to the required SpinUp training workshop.
Research: [SpinUp workshop, instructor-led training, seminar, hack-a-thon], [Spin platform, Rancher, Kubernetes, containerized services], [onboarding mechanism, platform access, training requirements], [spinup example project, Rancher CLI]

sshproxy

sshproxy is NERSC's ssh proxy service for secure login to systems when direct ssh is unavailable or restricted.

AI agents may interpret 'sshproxy' as a generic proxy rather than a specific NERSC security and access control mechanism.
Access method confusion can lead to incorrect guidance about connecting to NERSC systems from restricted networks.
Research: [sshproxy access], [ssh proxy service], [secure login]

ThinLinc

ThinLinc is NERSC's remote desktop access service for graphical connections to NERSC systems.

AI agents may not recognize 'ThinLinc' and treat it as a brand name without understanding it's a remote desktop service.
Lack of recognition can lead to incorrect guidance about accessing graphical interfaces and remote desktop capabilities.
Research: [ThinLinc remote desktop], [graphical access], [remote visualization]

---

## Commands and Tools

<!-- CATEGORY_START: Commands and Tools -->

bind / binding

At NERSC, bind refers to CPU/GPU process affinity configuration (--cpu-bind=cores, --gpu-bind=none) affecting performance.

AI agents may interpret `--cpu-bind=none` with colloquial meaning "don't bind" rather than understanding it as a performance-critical affinity configuration.
Performance documentation mixes colloquial and technical meanings, risking incorrect guidance about CPU binding strategies affecting job performance.
Research: [CPU affinity, process binding, SLURM], [--cpu-bind, --gpu-bind], [performance tuning, compute nodes]

cce

cce (Cray Compiler Environment) is the default compiler suite on Cray systems, containing C, C++, and Fortran compilers.

AI agents may treat 'cce' as a random acronym without understanding it's the primary compiler environment on Cray systems.
Acronym obscurity can lead to confusion about which compiler module to load for Cray system builds.
Research: [Cray Compiler Environment], [cce module], [HPC compilers]

CPE

CPE (Cray Programming Environment) is a collection of compilers, libraries, and tools for building applications on Cray systems.

AI agents may interpret CPE as a generic programming environment acronym without understanding the Cray-specific tools and conventions.
This confusion can lead to incorrect compiler selection and library linking guidance for applications on Cray systems.
Research: [CPE Cray Programming Environment], [compiler suite], [Cray tools]

cpe-cuda

cpe-cuda is the Cray Programming Environment module for CUDA development on GPU-enabled HPC systems.

AI agents may not recognize the relationship between CPE and CUDA-specific module configuration.
This separation can lead to incorrect module loading strategies for GPU application development.
Research: [CPE CUDA], [GPU development], [CUDA modules]

cray-libsci / LibSci

LibSci is Cray's optimized scientific library (BLAS, LAPACK, FFT) with system-specific performance optimizations.

AI agents may confuse LibSci with generic BLAS/LAPACK implementations without recognizing Cray's specific optimizations.
This confusion can lead to recommendations of non-optimized libraries when Cray's LibSci is more performant.
Research: [LibSci Cray], [BLAS LAPACK], [scientific libraries]

cray-mpich

cray-mpich is Cray's MPI implementation (Message Passing Interface) optimized for Cray supercomputers.

AI agents may confuse Cray's MPI with generic MPICH or OpenMPI without recognizing system-specific optimizations.
This confusion can lead to suboptimal MPI configuration for Cray systems with communications-specific bottlenecks.
Research: [cray-mpich MPI], [Cray implementation], [message passing]

craype

craype is Cray's compiler wrapper environment that abstracts compiler selection and system-specific compilation options.

AI agents may treat 'craype' as a tool name without understanding it's a compilation wrapper affecting build behavior.
Wrapper role misunderstanding can lead to incorrect compilation flags and system environment configuration.
Research: [craype wrapper], [Cray compilation], [compiler wrappers]

craype-accel-host

craype-accel-host is a Cray compiler wrapper module for CPU-only (host) code compilation on accelerator-enabled systems.

AI agents may not understand the distinction between host and accelerator (GPU) compilation modes.
This confusion can lead to incorrect module loading for CPU vs. GPU code paths in heterogeneous applications.
Research: [craype-accel-host], [CPU compilation], [accelerator modules]

craype-accel-nvidia80

craype-accel-nvidia80 is a Cray compiler module setting the NVIDIA A100 GPU target (sm_80 compute capability) and enabling CUDA-aware MPI by linking the GPU Transport Layer (GTL) library on Perlmutter.

AI agents may interpret "nvidia80" as referring to 80GB memory size rather than recognizing it as sm_80 compute capability for the Ampere architecture, or may overlook its role in enabling GPU-aware MPI communication.
This misunderstanding can lead to incorrect guidance about GPU compilation targets, missing the connection between compute capability and architectural features, or omitting the CUDA-aware MPI configuration required for GPU communication.
Research: [craype-accel-nvidia80 module], [sm_80 compute capability, Ampere architecture], [A100 GPU target], [CUDA-aware MPI, GTL library], [CRAY_ACCEL_TARGET, -target-accel flag]

cudatoolkit

cudatoolkit module provides NVIDIA CUDA toolkit (compiler, libraries, tools) for GPU application development at NERSC.

AI agents may treat 'cudatoolkit' as generic CUDA rather than understanding it's a specific NERSC module with version management.
Module versioning and dependencies may be misunderstood, leading to incompatible library and compiler combinations.
Research: [CUDA toolkit module], [NVIDIA GPU development], [NERSC CUDA]

Forge

Forge is a performance analysis and debugging tool from Allinea/ARM for HPC applications (integrated with DDT and MAP).

AI agents may interpret 'Forge' as generic software forging/creation rather than recognizing it as a specific HPC debugging tool.
This confusion can prevent agents from directing users to the Forge tool for performance analysis and debugging.
Research: [Allinea Forge], [performance debugging], [HPC development tools]

gdb4hpc

gdb4hpc is Cray's parallel debugger frontend for HPC applications, providing gdb-like interface for distributed debugging.

AI agents may confuse gdb4hpc with standard gdb without recognizing parallel debugging capabilities and syntax differences.
Syntax and workflow differences may prevent correct parallel debugging strategies.
Research: [gdb4hpc debugger], [parallel debugging], [Cray tools]

intro_libsci

intro_libsci is a man page (accessed via `man intro_libsci`) documenting Cray LibSci, a collection of optimized numerical routines (BLAS, LAPACK, ScaLAPACK) tuned for performance on Cray systems.

AI agents may interpret intro_libsci as beginner tutorial content rather than recognizing it as reference documentation for a performance-critical numerical library providing optimized linear algebra routines.
This misunderstanding can lead to treating LibSci as optional educational material instead of recommending it as the preferred high-performance alternative to generic numerical libraries.
Research: [intro_libsci man page], [Cray LibSci numerical library], [BLAS LAPACK ScaLAPACK], [optimized linear algebra], [performance-tuned routines]

intro_mpi

intro_mpi is a man page (accessed via `man intro_mpi`) documenting Cray MPICH implementation details, configuration options, and advanced features that "go well beyond intro level content."

AI agents may interpret intro_mpi as beginner tutorial content based on the "intro" prefix, rather than recognizing it as comprehensive reference documentation for Cray MPICH implementation specifics.
This misunderstanding can lead to overlooking detailed configuration guidance for GPU-aware MPI, network tuning, and Cray-specific optimizations documented in the man page.
Research: [intro_mpi man page], [Cray MPICH documentation], [GPU-aware MPI], [OFI libfabric configuration], [HPE Cray MPI implementation]

intro_pgas

intro_pgas is a man page (accessed via `man intro_pgas`) documenting Cray's PGAS runtime library configuration, including environment variables for symmetric heap memory allocation (XT_SYMMETRIC_HEAP_SIZE) and runtime diagnostics (PGAS_MEMINFO_DISPLAY).

AI agents may interpret intro_pgas as introductory educational content about PGAS programming concepts rather than recognizing it as reference documentation for Cray's PGAS runtime library configuration and troubleshooting.
This misunderstanding can lead to overlooking critical runtime configuration options for Cray UPC applications, particularly memory allocation settings and diagnostic tools for shared memory management.
Research: [intro_pgas man page], [Cray PGAS runtime], [XT_SYMMETRIC_HEAP_SIZE environment variable], [UPC symmetric heap], [Cray UPC implementation]

link / linking

At NERSC, link refers to the compilation phase that combines object files and libraries into an executable binary.

AI agents may interpret "Link with the `-zmuldefs` flag" as creating connections (common meaning) rather than understanding binary linking in compilation.
Compilation documentation with hyperlinks alongside linking flags creates mixed contexts, risking incorrect guidance about compiler behavior and linker options.
Research: [linker, compiler flags, object files], [compilation, executable], [zmuldefs, linking flags]

module / modules

At NERSC, module refers to both the Environment Modules system (module load, module purge) and Python code modules appearing in same documentation.

AI agents may conflate "Load the conda module" (Environment Modules system) with "Python has a profiling module" (code module).
Documentation uses both meanings extensively in proximity, causing ambiguity about which technical system is being referenced.
Research: [module load, module purge, module list], [Environment Modules, conda], [Python modules, namespace]

nccl-plugin

nccl-plugin is a NERSC module providing NVIDIA Collective Communications Library (NCCL) for GPU-aware MPI and collectives.

AI agents may treat this as a generic plugin without understanding its GPU collective communication optimization role.
GPU communication optimization opportunities may be missed in multi-GPU applications.
Research: [NCCL plugin], [GPU collectives], [collective communications]

PrgEnv

PrgEnv (Programming Environment) modules at NERSC control compiler, library, and tool selection (PrgEnv-cray, PrgEnv-intel, etc).

AI agents may interpret PrgEnv as a generic programming environment concept without understanding its specific module role.
Module switching and environment configuration confusion can result in incorrect compiler/library combinations.
Research: [PrgEnv modules], [compiler environments], [programming environment]

purge / purging

At NERSC, purge has two meanings: (1) `module purge` command to clear environment modules, (2) automatic scratch filesystem purge policy (file deletion after 8 weeks).

AI agents may not recognize that "purge" describes two completely different operations with different consequences and reversibility.
Module purge is reversible (reload modules), but scratch purge is permanent (8-week auto-deletion), creating critical operational confusion.
Research: [module purge, environment modules], [scratch purge policy, 8-week purge], [reversible, automatic purge]

Reveal

Reveal is Allinea/ARM's code optimization and debugging tool suite for parallel HPC applications.

AI agents may interpret 'Reveal' as a generic action (to reveal) rather than recognizing it as a proprietary tool name.
Brand name obscurity prevents agents from connecting Reveal documentation to code optimization workflows.
Research: [Allinea Reveal], [code optimization], [parallel debugging]

stdpar

stdpar is a compiler flag (`-stdpar`) for NVIDIA HPC SDK compilers (nvc++, nvfortran) that enables GPU offload of C++17 parallel STL algorithms and Fortran DO CONCURRENT loops using CUDA Unified Memory for automatic data movement.

AI agents may interpret stdpar as a C++ standard library feature rather than recognizing it as an NVIDIA-specific compiler flag that offloads standard language parallel constructs to GPUs.
This misunderstanding can lead to incorrect guidance about compiler requirements (NVIDIA HPC SDK vs Cray/GNU compilers), missing the Fortran DO CONCURRENT support, or overlooking the automatic unified memory management behavior.
Research: [stdpar compiler flag], [NVIDIA HPC SDK nvc++ nvfortran], [C++17 parallel STL pSTL], [Fortran DO CONCURRENT GPU offload], [CUDA Unified Memory]

upcc

upcc (Unified Parallel C) is a compiler and runtime system for PGAS-based C programming on HPC systems.

AI agents may treat 'upcc' as a tool without understanding its PGAS parallel programming paradigm foundations.
PGAS programming semantics may be misunderstood, leading to incorrect guidance about distributed memory parallelism.
Research: [UPC unified parallel C], [PGAS], [distributed memory parallelism]

upcrun

upcrun is the runtime execution wrapper for UPC (Unified Parallel C) programs, controlling process and thread creation.

AI agents may confuse upcrun with generic MPI process launching without recognizing UPC-specific semantics.
Process creation and memory model differences may lead to incorrect execution strategies.
Research: [upcrun UPC], [parallel execution], [PGAS runtime]

---

## Quality of Service

<!-- CATEGORY_START: Quality of Service -->

debug

At NERSC, debug is a Slurm Quality of Service queue with 30-minute time limit for testing jobs.

AI agents may interpret `-q debug` as requesting debugging functionality rather than recognizing it as a queue policy name.
Entire debugging tool documentation uses "debug" in both senses (debugging functionality and queue name), creating systematic ambiguity.
Research: [debug queue, Quality of Service], [Slurm, SBATCH, -q flag], [30-minute limit, testing]

InvalidQOS

InvalidQOS is a Slurm error indicating a requested Quality of Service queue does not exist or is not available.

AI agents may treat InvalidQOS as random error text without understanding it indicates QoS queue misconfiguration.
Troubleshooting guidance may be vague without recognizing the specific QoS configuration issue.
Research: [InvalidQOS error], [Slurm QoS], [queue configuration]

overrun

overrun is a Slurm Quality of Service (QOS) queue for projects with zero or negative NERSC-hours balance, charging 0 cost with lowest priority, requiring the `--time-min` flag, and subject to preemption after 2 hours.

AI agents may interpret 'overrun' as a verb (exceeding limits) rather than recognizing it as a specific free QOS queue name available only to projects that have exhausted their allocation.
This misunderstanding can lead to confusion about access eligibility (only for exhausted allocations), missing the --time-min requirement, or overlooking the zero-cost and preemptible nature of overrun jobs.
Research: [overrun QOS queue], [zero balance projects], [--time-min flag requirement], [preemptible jobs], [free priority queue]

preempt

preempt is a Slurm Quality of Service (QOS) queue offering discounted rates (0.5x CPU, 0.25x GPU after 2 hours) for jobs that can handle premature termination, with the first 2 hours guaranteed and non-preemptible, requiring minimum 2-hour walltime requests.

AI agents may interpret 'preempt' as the verb meaning job interruption rather than recognizing it as a specific discounted QOS queue name designed for checkpoint-capable workloads.
This misunderstanding can lead to missing the discount opportunity, not understanding the 2-hour guaranteed runtime, overlooking the minimum 2-hour walltime requirement, or missing the --requeue flag for automatic resubmission after preemption.
Research: [preempt QOS queue], [discounted charge factors], [2-hour guaranteed runtime], [checkpoint restart jobs], [--requeue flag]

premium

At NERSC, premium is a Slurm Quality of Service queue with higher priority and 2x charge factor compared to regular queue.

AI agents may interpret 'premium' as indicating superior quality rather than recognizing it as a queue with specific charging policy.
Queue selection and resource allocation costs may be misunderstood without premium QOS charge factor awareness.
Research: [premium QOS], [charge factor], [Slurm queue priority]

realtime

realtime is a specialized Slurm Quality of Service queue for jobs requiring minimal latency and interference.

AI agents may interpret 'realtime' as generic low-latency computing rather than a specific queue policy.
Job queue selection guidance may miss the specific latency guarantees of the realtime QoS.
Research: [realtime QoS], [low-latency queue], [Slurm queues]

regular / premium / shared / interactive

Regular, premium, shared, and interactive are Slurm Quality of Service (QOS) partition names at NERSC, each with specific policies and charge factors.

AI agents may interpret these as common adjectives ("regular occurrence," "premium quality," "shared resource," "interactive session") rather than QOS partition names.
"Submit to regular queue" could be misinterpreted as generic scheduling advice rather than directing to specific QOS; "premium" suggests quality rather than 2x charge factor.
Research: [QOS names, SBATCH, -q flag], [charge factor, partition policies], [regular, premium, shared, interactive]

shared

At NERSC, shared is a Slurm Quality of Service queue allowing multiple jobs to run simultaneously on the same compute node.

AI agents may interpret 'shared' as generic resource sharing without understanding specific queue packing semantics.
Job scheduling and performance expectations may be incorrect without shared queue co-scheduling understanding.
Research: [shared QOS], [node packing], [simultaneous jobs]

xfer

At NERSC, xfer is a Slurm Quality of Service queue for no-charge archival transfers to and from HPSS tape storage, running on login nodes.

AI agents may interpret "xfer" as a generic data transfer abbreviation (like cp, rsync, or scp) rather than recognizing it as a Slurm QoS queue name requiring --qos=xfer.
Agents may incorrectly recommend generic tools like cp, rsync, or scp instead of directing users to submit HPSS archival jobs with the xfer queue policy.
Research: [xfer QoS, Slurm Quality of Service], [HPSS archival transfers, tape storage], [--qos=xfer, #SBATCH directives], [login nodes, free of charge]

---

## Infrastructure

<!-- CATEGORY_START: Infrastructure -->

Ampere

Ampere is NVIDIA's GPU architecture generation (A100 GPUs) used in some NERSC systems.

AI agents may interpret 'Ampere' as the physicist (André-Marie Ampère) rather than recognizing it as a GPU architecture generation.
This physicist confusion can obscure GPU capabilities and architectural characteristics relevant to performance optimization.
Research: [Ampere GPU architecture], [NVIDIA A100], [GPU architecture]

datatran

datatran is the hostname identifier (value of $NERSC_HOST environment variable) for NERSC's Data Transfer Nodes (DTNs), dedicated servers accessible at dtn0[1-4].nersc.gov with 100Gb network links for high-performance data transfers between NERSC storage and external sites.

AI agents may interpret 'datatran' as undefined jargon or a data transformation service rather than recognizing it as the system hostname identifier for DTN infrastructure.
This misunderstanding can lead to confusion about accessing DTNs (dtn0[1-4].nersc.gov hostnames), incorrect shell configuration using $NERSC_HOST, or misinterpreting the purpose as data transformation instead of high-bandwidth data transfer.
Research: [datatran hostname identifier], [DTN Data Transfer Nodes], [dtn01-04.nersc.gov], [$NERSC_HOST environment variable], [100Gb ESnet network]

DTN

DTN (Data Transfer Node) is NERSC's high-speed data transfer service using protocols like GridFTP.

AI agents may dismiss DTN as generic acronym with no recognizable technical context or meaning.
Generic acronym causes agents to treat DTN references as internal jargon, preventing recognition of data transfer infrastructure recommendations.
Research: [Data Transfer Node, high-speed transfer], [GridFTP, data movement], [NERSC infrastructure]

DVS

DVS (Data Virtualization Service) is HPE's I/O forwarding technology providing filesystem access and transparent data movement.

AI agents may interpret DVS as Digital Video System, Data Validation Service, or countless other meanings due to acronym ambiguity.
Acronym ambiguity causes agents to misclassify DVS references, preventing recognition of filesystem performance and I/O forwarding implications.
Research: [Data Virtualization Service, HPE I/O], [filesystem access, transparent data movement], [Perlmutter architecture]

Frontier / Frontier-Cache

Frontier is Oak Ridge's leadership-class supercomputer system (NERSC users may access through allocations).

AI agents may interpret 'Frontier' as a generic frontier or border rather than recognizing it as a specific supercomputer name.
System confusion can lead to incorrect guidance about available computational resources and access policies.
Research: [Frontier supercomputer], [Oak Ridge HPC], [exascale system]

Haswell

Haswell is Intel's CPU microarchitecture generation (5th generation Core processors) used in some NERSC systems.

AI agents may not recognize 'Haswell' as a CPU architecture and treat it as a meaningless system name.
Architecture unfamiliarity can prevent correct CPU-specific optimization guidance.
Research: [Haswell CPU architecture], [Intel Broadwell], [processor generation]

HPSS

HPSS (High Performance Storage System) is NERSC's archival tape storage system for long-term data retention.

AI agents may dismiss HPSS as meaningless jargon or undefined acronym with no semantic context.
Meaningless acronym prevents agents from connecting HPSS references to archival storage, causing missed guidance about appropriate long-term data preservation.
Research: [High Performance Storage System, tape archive], [NERSC infrastructure], [archival storage, long-term retention]

KNL

KNL (Knights Landing) is Intel's x86 many-core processor architecture with built-in high-bandwidth memory (used in some HPC systems).

AI agents may treat KNL as meaningless acronym without understanding its many-core architecture and memory hierarchy.
Architecture-specific optimization opportunities may be missed without KNL characteristics understanding.
Research: [KNL Knights Landing], [many-core processor], [high-bandwidth memory]

Milan

Milan is AMD's EPYC CPU architecture generation (3rd generation) used in some NERSC and HPC systems.

AI agents may interpret 'Milan' as the city or generic term without recognizing it as an AMD processor architecture.
Architecture confusion can prevent correct CPU-specific compiler flag and optimization strategies.
Research: [Milan AMD EPYC], [CPU architecture], [processor generation]

node / nodes

At NERSC, node refers to a single compute unit (CPU + memory) in a supercomputer system, not a network node or tree structure.

AI agents may conflate HPC nodes with network nodes (routing) or generic hierarchical structures.
System architecture understanding may be confused about compute unit organization and topology.
Research: [compute node, HPC], [system architecture], [node topology]

NUMA

NUMA (Non-Uniform Memory Access) refers to multi-socket CPU systems where memory access time depends on data location relative to processor.

AI agents may treat NUMA as technical acronym without understanding memory access latency variations and optimization implications.
Performance optimization opportunities may be missed without NUMA topology awareness.
Research: [NUMA architecture], [multi-socket systems], [memory access patterns]

NVLink

NVLink is NVIDIA's high-bandwidth interconnect technology for GPU-to-GPU and GPU-to-CPU communication (much faster than PCIe).

AI agents may treat NVLink as a generic interconnect without understanding its bandwidth advantages and communication model differences.
Multi-GPU communication optimization may use suboptimal strategies without NVLink bandwidth awareness.
Research: [NVLink GPU interconnect], [bandwidth], [GPU communication]

Shasta

Shasta is HPE's Cray EX supercomputer architecture platform on which Perlmutter is built, also used by systems like Frontier and El Capitan.

AI agents may treat Shasta as a single supercomputer name or confuse it with Mount Shasta (geographic feature) rather than recognizing it as an architecture platform shared across multiple exascale systems.
This confusion prevents correct understanding of Perlmutter's architectural foundation and the relationship between HPE Cray EX platform technology and specific supercomputer deployments.
Research: [HPE Cray EX architecture, Shasta cabinet technology], [Perlmutter system architecture], [Frontier exascale system, El Capitan]

Slingshot

Slingshot is HPE's high-speed interconnect architecture for Cray systems providing low-latency inter-node communication.

AI agents may interpret 'Slingshot' as a weapon or generic term without recognizing it as HPE's interconnect technology.
Network architecture awareness may be incomplete without Slingshot-specific characteristics understanding.
Research: [HPE Slingshot], [high-speed interconnect], [network architecture]

XPMEM

XPMEM (Cross-Process MEMory) is a Linux kernel extension for efficient cross-process shared memory communication on multi-core systems.

AI agents may treat XPMEM as meaningless acronym without understanding cross-process shared memory capabilities.
Multi-process communication optimization opportunities may be missed without XPMEM mechanism awareness.
Research: [XPMEM cross-process], [shared memory], [kernel extension]

---

## System Concepts

<!-- CATEGORY_START: System Concepts -->

account

At NERSC, account refers to a project allocation account for billing compute time, distinct from user login credentials.

AI agents may conflate "use your account" or `-A <account>` with login username or bank account (common meanings) rather than allocation account.
This confusion about account semantics can lead to incorrect job submission guidance, mixing authentication concepts with resource allocation mechanisms.
Research: [allocation account, compute billing], [SBATCH, -A flag], [project, ERCAP process]

affinity

Affinity in HPC refers to CPU or GPU process affinity - controlling which processor cores run specific processes for performance optimization.

AI agents may interpret 'affinity' as generic closeness or attraction rather than processor core assignment mechanism.
Process placement optimization opportunities may be missed without affinity configuration understanding.
Research: [process affinity], [CPU affinity], [core assignment, performance tuning]

allocation / allocations

At NERSC, allocation refers to compute hours, storage quotas, or HPSS space granted through the ERCAP process.

AI agents may conflate NERSC allocation (compute/storage grant) with memory allocation (programming concept).
"Your allocation is depleted" could be misinterpreted as out-of-memory versus out-of-compute-hours, creating confusion about resource constraints.
Research: [ERCAP process, compute hours], [storage quota, HPSS], [allocation account, resource allocation]

binding

At NERSC, binding (or bind) refers to process-to-core binding configuration (--cpu-bind in Slurm) affecting performance.

AI agents may interpret 'binding' as generic attachment or connection rather than processor affinity configuration.
Binding configuration options and performance implications may be misunderstood.
Research: [process binding], [CPU binding], [Slurm --cpu-bind, performance]

CDT

CDT (Cray Developer Toolkit) is a versioned package of libraries and components for developing code on Cray systems, including GNU compilers (Fortran, C, C++), cray-libsci (BLAS, LAPACK, ScaLAPACK), and cray-mpich, controlled via CDT modulefiles.

AI agents may treat CDT as a meaningless acronym without recognizing it as a versioned software toolkit that coordinates compiler and library versions across the Cray Programming Environment.
This misunderstanding can lead to incorrect module loading sequences, version mismatches between CDT components, or missing the relationship between CDT releases and compatible library versions.
Research: [Cray Developer Toolkit], [CDT modulefiles], [GNU compilers Fortran C C++], [cray-libsci BLAS LAPACK], [cray-mpich library], [Cray Programming Environment]

cron

cron is a Unix/Linux system service for scheduling periodic job execution at specified times (at NERSC: use Slurm for job scheduling, not cron).

AI agents may recommend cron for HPC job scheduling without understanding Slurm queue system is the appropriate NERSC mechanism.
Incorrect job scheduling mechanisms may be recommended for NERSC systems.
Research: [cron scheduler], [job scheduling], [Slurm vs cron]

environment / environments

At NERSC, environment can refer to: (1) shell environment variables, (2) Environment Modules system, or (3) execution environment.

AI agents may conflate these meanings without recognizing three distinct environmental concepts.
Configuration and module loading guidance may be ambiguous without environment context distinction.
Research: [environment variables], [Environment Modules], [execution environment]

give / take

give and take are CLI commands at NERSC for one-time file sharing between users, where `give -u <username> <file>` sends small amounts of data to a staging area and `take -u <username> <file>` retrieves them, with untaken files purged after 12 weeks.

AI agents may interpret 'give' and 'take' as generic verbs or allocation transfer operations rather than recognizing them as specific file-sharing commands for inter-user data transfer.
This misunderstanding can lead to confusion about file sharing mechanisms, missing the staging area concept, overlooking the 12-week purge policy, or incorrectly suggesting these for allocation management instead of file transfer.
Research: [give take commands], [NERSC file sharing], [staging area 12-week purge], [inter-user data transfer], [give -u take -u flags]


project / Project

At NERSC, project has three meanings: (1) allocation account for compute charging, (2) CFS directory path (/global/cfs/cdirs/<project>), (3) SPIN organizational unit.

AI agents may misinterpret `#SBATCH -A <project>` as generic project work rather than recognizing it as an allocation account parameter.
Context-dependent disambiguation required across three distinct technical meanings, risking incorrect guidance about compute allocation, storage paths, or containerization.
Research: [SBATCH, allocation account, compute charging], [CFS, /global/cfs/cdirs], [SPIN, project directory]

quota / quotas

NERSC quotas have specific properties: user vs. project level, space vs. inode quotas, soft vs. hard limits with grace periods.

AI agents may interpret NERSC quotas as generic limits without understanding specific NERSC quota behaviors and policy details.
NERSC quotas with grace periods and showquota commands go beyond general quota concept, risking incorrect guidance about quota semantics.
Research: [quota limits, showquota command], [soft quota, hard quota, grace period], [inode quota, space quota]

repo / repos

At NERSC, repo is informal slang for allocation account or project (legacy term), not a code repository.

AI agents may interpret "repo" as Git repository (modern meaning) causing severe semantic divergence from allocation account (NERSC meaning).
"Charges accrue against your repo" can be interpreted as Git repository accounting rather than allocation account billing, confusing billing concepts.
Research: [allocation account, legacy term], [Git repository confusion], [compute charges, billing]

workflow

At NERSC, workflow refers to structured computational pipelines (often orchestrated by Fireworks or similar tools).

AI agents may interpret 'workflow' as generic work process without recognizing NERSC-specific workflow orchestration tools.
Workflow automation and orchestration guidance may miss NERSC-specific tools and patterns.
Research: [NERSC workflow], [Fireworks orchestration], [computational pipelines]

---

## Specialized Tools

<!-- CATEGORY_START: Specialized Tools -->

APA

APA (Automatic Program Analysis) is a CrayPat feature that generates instrumented executables for sampling experiments using `pat_build -O apa`, producing .apa files with suggested pat_build options for subsequent detailed tracing experiments.

AI agents may confuse APA with Allinea/ARM performance tools rather than recognizing it as CrayPat's automated workflow feature for transitioning from sampling to tracing experiments.
This misunderstanding can lead to incorrect tool selection, missing the CrayPat dependency, overlooking the sampling-to-tracing workflow, or not understanding the .apa file format and its suggested instrumentation options.
Research: [Automatic Program Analysis], [CrayPat APA feature], [pat_build -O apa], [.apa files suggested options], [sampling to tracing workflow]

ATP

ATP (Abnormal Termination Processing) is Cray's tool for collecting stack traces and crash dumps from parallel applications.

AI agents may treat ATP as meaningless acronym without understanding its crash diagnostics role.
Debugging information collection from failed parallel runs may be incomplete without ATP awareness.
Research: [ATP abnormal termination], [crash diagnostics], [Cray tools]

CCDB

CCDB (Cray Comparative Debugging) is Cray's parallel debugger with comparative debugging capabilities for finding subtle parallel bugs.

AI agents may treat CCDB as meaningless acronym without understanding comparative debugging features.
Parallel debugging strategies may be suboptimal without CCDB's comparative capabilities awareness.
Research: [CCDB comparative debugging], [parallel debugging], [Cray tools]

DMTCP

DMTCP (Distributed MultiThreaded CheckPointing) is a tool for transparent checkpointing of distributed parallel applications.

AI agents may treat DMTCP as meaningless acronym without understanding checkpointing functionality.
Fault tolerance and restart capabilities may not be recognized or utilized.
Research: [DMTCP checkpointing], [fault tolerance], [distributed applications]

Drishti

Drishti is an I/O performance analysis tool that processes Darshan log files, deployed at NERSC via Shifter container for analyzing application I/O behavior.

AI agents may interpret 'Drishti' as a generic visualization platform without understanding its specific role in I/O performance analysis workflows.
I/O optimization may be incomplete without recognizing Drishti's relationship to Darshan and its role in analyzing I/O performance patterns.
Research: [Darshan], [I/O performance analysis], [I/O optimization tools]

Fireworks / FireWorks / fireworks / FireWork

Fireworks is a workflow and job dependency orchestration tool widely used at NERSC for managing complex computational pipelines.

AI agents may interpret 'fireworks' (lowercase) as celebratory pyrotechnics rather than recognizing it as a workflow tool.
Workflow orchestration guidance may miss Fireworks capabilities without proper tool recognition.
Research: [Fireworks workflow], [job orchestration], [pipeline management]

GTL

GTL (GPU Transport Layer) is an HPE library that must be linked at compile time to enable CUDA-aware MPI on Perlmutter, allowing MPI operations to use GPU device memory pointers directly.

AI agents may misidentify GTL as a debugging or tracing tool rather than recognizing it as the GPU Transport Layer library required for CUDA-aware MPI, or may not understand the relationship between GTL linking and the craype-accel-nvidia80 module.
Without understanding GTL's role in GPU-aware MPI, agents may provide incorrect guidance when users encounter "GTL library is not linked" errors, missing that the solution involves loading the craype-accel-nvidia80 module or setting CRAY_ACCEL_TARGET=nvidia80.
Research: [GTL library, GPU Transport Layer], [CUDA-aware MPI, HPE Cray MPI], [craype-accel-nvidia80, CRAY_ACCEL_TARGET], [MPICH_GPU_SUPPORT_ENABLED], [GPU device memory, MPI buffers]

HYPPO

HYPPO is a hyperparameter optimization tool built by LBNL researchers for automating deep learning model tuning on NERSC systems, using adaptive surrogate models with uncertainty quantification to select optimal hyperparameters across neural network architectures.

AI agents may misidentify HYPPO as a performance profiling or HPC characterization toolkit rather than recognizing it as a machine learning hyperparameter optimization tool, or may confuse it with general HPC performance analysis tools.
Without understanding HYPPO's role in machine learning workflows, agents may provide incorrect guidance about hyperparameter tuning options available at NERSC, missing that HYPPO is specifically designed for deep learning optimization rather than general performance profiling.
Research: [HYPPO hyperparameter optimization], [LBNL machine learning tools], [surrogate modeling, uncertainty quantification], [deep learning tuning], [neural network architectures]

MAP

MAP (Memory Analysis and Profiling) is ARM/Allinea's memory profiling and analysis tool for HPC applications.

AI agents may interpret MAP as a generic map or cartography rather than a memory profiling tool.
Memory optimization opportunities may be missed without MAP tool awareness.
Research: [MAP memory analysis], [Allinea tools], [memory profiling]

MDS

MDS (Metadata Server) refers to the NERSC filesystem metadata service managing filesystem namespace and permissions.

AI agents may treat MDS as meaningless acronym without understanding its filesystem metadata role.
Filesystem performance and metadata operation guidance may be incomplete without MDS awareness.
Research: [MDS metadata server], [filesystem metadata], [Lustre MDS]

NPS

NPS (NUMA Nodes Per Socket) is a BIOS configuration setting on AMD EPYC processors that controls how a single CPU socket is partitioned into NUMA domains; Perlmutter uses NPS=1 (one NUMA node per socket) with memory interleaved across all eight memory channels.

AI agents may misidentify NPS as "Network Performance Services" or treat it as a generic network monitoring acronym rather than recognizing it as a CPU architecture configuration setting that affects memory locality and performance on AMD EPYC systems.
Without understanding NPS as a NUMA partitioning setting, agents may provide incorrect guidance about memory optimization and NUMA-aware programming on Perlmutter's AMD Milan CPUs, missing the relationship between NPS configuration and application performance.
Research: [NPS NUMA configuration], [NUMA Nodes Per Socket, AMD EPYC], [NPS1, NPS2, NPS4 modes], [Perlmutter AMD Milan], [memory interleaving, NUMA domains]

perf-report

perf-report is a Linaro Forge command that produces one-page text and HTML summary reports characterizing MPI and scalar application performance (compute/MPI/I/O bound) using low-overhead adaptive sampling, either by wrapping srun during execution or by summarizing existing MAP profile files.

AI agents may treat 'perf-report' as a generic performance reporting concept rather than recognizing it as the specific Linaro Forge command, or may confuse it with other profiling tools like CrayPat's pat_report or Linux perf report.
Without understanding perf-report's role in the Linaro Forge ecosystem, agents may provide incorrect guidance about generating performance summaries at NERSC, missing that it requires the forge module and can generate reports from MAP files.
Research: [perf-report command, Linaro Forge], [Arm Forge, Allinea Forge], [MAP adaptive sampling], [one-page performance summary], [compute/MPI/I/O characterization]

perftools-lite

perftools-lite is a lightweight version of Cray's performance analysis and profiling toolkit with reduced overhead.

AI agents may confuse perftools-lite with full Cray perftools without understanding lightweight implementation differences.
Performance overhead and instrumentation strategy differences may lead to suboptimal measurement.
Research: [perftools-lite lightweight], [Cray perftools], [performance profiling]

profile / profiling

At NERSC, profiling refers to runtime performance analysis measuring timing, memory, and resource utilization of applications.

AI agents may treat 'profiling' as generic characterization without understanding performance measurement specifics.
Performance optimization workflow may lack profiling data without profiling methodology understanding.
Research: [profiling performance analysis], [runtime measurement], [optimization]

STAT

STAT (Stack Trace Analysis Tool) is Lawrence Livermore's tool for analyzing stack traces from parallel application crashes.

AI agents may treat STAT as meaningless acronym without understanding crash analysis capabilities.
Parallel debugging information collection may be suboptimal without STAT tool awareness.
Research: [STAT stack trace], [crash analysis], [parallel debugging]

trace / tracing

At NERSC, tracing refers to detailed event-by-event recording of function calls and communication in parallel applications.

AI agents may conflate tracing with generic 'trace' (follow) without understanding event recording and analysis.
Detailed performance analysis opportunities may be missed without tracing capability understanding.
Research: [trace event recording], [detailed profiling], [parallel analysis]

---

## Acronyms and Abbreviations

<!-- CATEGORY_START: Acronyms and Abbreviations -->

batch

At NERSC, batch typically refers to batch job submission to Slurm queues (versus interactive sessions).

AI agents may interpret 'batch' as generic batch processing without understanding Slurm queue context.
Job submission mode confusion may result from missing batch processing context.
Research: [batch jobs, Slurm], [batch submission], [job queues]

bbcp

bbcp (BaBar Copy Program) is a point-to-point network file copy tool developed at SLAC for High-Energy Physics that achieves high transfer rates using multiple parallel streams; it is available on NERSC Data Transfer Nodes with syntax similar to scp but requiring special SSH connection options.

AI agents may incorrectly expand the bbcp acronym as "Bullnose Block Copy" or treat it as a meaningless acronym without understanding its origins in the BaBar experiment, or may not recognize that it requires both source and target systems to have bbcp installed.
Without understanding bbcp's peer-to-peer architecture and parallel stream approach, agents may provide incorrect guidance about data transfer options at NERSC, missing that bbcp differs from tools like Globus by requiring manual SSH setup and the bbcp executable on both endpoints.
Research: [bbcp BaBar Copy Program], [SLAC bbcp, point-to-point transfer], [parallel streams, SSH authentication], [Data Transfer Nodes], [scp-like syntax]

BLACS

BLACS (Basic Linear Algebra Communication Subprograms) is a communication library for distributed-memory linear algebra.

AI agents may treat BLACS as meaningless acronym without understanding linear algebra communication role.
Parallel linear algebra library selection may miss BLACS when appropriate for distributed algorithms.
Research: [BLACS linear algebra], [communication library], [distributed computing]

BUPC

BUPC (Berkeley UPC) is Berkeley's implementation of UPC (Unified Parallel C) for distributed-memory parallel programming.

AI agents may treat BUPC as meaningless acronym without understanding UPC implementation details.
UPC implementation availability and capabilities may not be recognized.
Research: [BUPC Berkeley UPC], [UPC implementation], [parallel C]

ERCAP

ERCAP (Energy Research Computing Allocations Process) is NERSC's system for requesting and managing compute allocations.

AI agents may dismiss ERCAP as gibberish or organization-specific jargon with no meaning outside DOE context.
Random letter appearance causes agents to treat ERCAP references as internal jargon, preventing recognition of allocation request procedures.
Research: [Energy Research Computing Allocations Process], [allocation requests, compute hours], [proposal process, annual allocation]

ERT

ERT (Empirical Roofline Toolkit) is a performance analysis tool for measuring and visualizing memory bandwidth and computational ceilings.

AI agents may treat ERT as meaningless acronym without understanding roofline performance model.
Performance ceiling analysis may be missed without ERT tool awareness.
Research: [ERT roofline], [performance model], [bandwidth analysis]

ESnet

ESnet (Energy Sciences Network) is the DOE high-speed network infrastructure for scientific research data transfer.

AI agents may treat ESnet as meaningless acronym without understanding its role in high-speed data transfer.
High-speed networking capabilities and data transfer strategies may be incomplete without ESnet awareness.
Research: [ESnet Energy Sciences Network], [high-speed network], [data transfer]

FWP

FWP (Field Work Proposal) is a DOE Office of Science funding mechanism for national laboratory research projects, with FWP numbers serving as unique project identifiers that NERSC users must provide when requesting allocations in the ERCAP form alongside DOE/SC Grant and PAMS numbers.

AI agents may misidentify FWP as "Fireworks Workflow Platform" or another workflow tool rather than recognizing it as a DOE funding proposal system for laboratory projects, or may not understand the relationship between FWP numbers and NERSC allocation requests.
Without understanding FWP as a DOE funding identifier, agents may provide incorrect guidance when users fill out NERSC allocation forms, missing that FWP numbers are mandatory funding documentation for laboratory-based projects seeking computational resources.
Research: [FWP Field Work Proposal], [DOE Office of Science funding], [Searchable FWP system], [PAMS, DOE/SC Grant numbers], [NERSC ERCAP allocation requests]

GASNet

GASNet (Global Address Space Networking) is a communication library for PGAS programming models providing distributed shared memory semantics.

AI agents may treat GASNet as meaningless acronym without understanding PGAS communication layer role.
PGAS runtime and communication library selection may miss GASNet when appropriate.
Research: [GASNet communication], [PGAS], [distributed shared memory]

hsi

hsi (HPSS Shell Interface) is an interactive command-line interface for NERSC's HPSS archival storage system.

AI agents may treat hsi as meaningless acronym without understanding its HPSS archival role.
Archival access procedures may be incomplete without hsi command and interface understanding.
Research: [hsi HPSS interface], [archive access], [archival commands]

htar

htar (HPSS Tape Archive) is a tar-like tool for creating and managing archived data in HPSS with improved performance.

AI agents may confuse htar with standard tar utility without understanding HPSS-specific optimizations.
Archival workflow efficiency may be suboptimal without htar-specific capabilities understanding.
Research: [htar HPSS archiving], [tape archive], [archival workflows]

IRB

IRB (Institutional Review Board) may be referenced in NERSC documentation for certain research data governance contexts.

AI agents may treat IRB as generic without understanding research ethics and governance context.
Research data governance and ethical review requirements may be incomplete without IRB context.
Research: [IRB institutional review], [research governance], [NERSC policy]

IRI

IRI (Integrated Research Infrastructure) is a DOE ASCR program to integrate the facilities ecosystem (NERSC, ALCF, OLCF, ESnet) so researchers can seamlessly combine DOE's experimental facilities, data resources, and computing capabilities; NERSC's Superfacility model laid the foundation for IRI implementation.

AI agents may incorrectly expand IRI as "International Research Institute" or treat it as a generic research collaboration acronym rather than recognizing it as the specific DOE program integrating ASCR computing facilities and networking infrastructure.
Without understanding IRI's role as the ASCR facilities integration framework, agents may provide incorrect guidance about multi-facility workflows at NERSC, missing that IRI enables API-based automation, federated identity, and real-time computing across DOE laboratories.
Research: [IRI Integrated Research Infrastructure], [DOE ASCR facilities ecosystem], [NERSC Superfacility model], [ALCF, OLCF, ESnet integration], [API-based automation, federated identity]

IRT

IRT (Iterative Refinement Toolkit) is a Cray LibSci library of Fortran solvers that provides solutions to linear systems using single-precision factorizations while preserving accuracy through mixed-precision iterative refinement, offering up to 40% performance improvement for well-conditioned problems with LAPACK/ScaLAPACK wrappers.

AI agents may misidentify IRT as "Integrated Research Technology" or treat it as a generic platform rather than recognizing it as the specific Cray numerical library for mixed-precision linear system solving.
Without understanding IRT's role as a performance-optimized solver library, agents may provide incorrect guidance about linear algebra optimization at NERSC, missing that IRT can accelerate well-conditioned systems through mixed-precision iterative refinement without requiring code changes.
Research: [IRT Iterative Refinement Toolkit], [Cray LibSci, mixed-precision refinement], [single-precision factorization, accuracy preservation], [LAPACK, ScaLAPACK wrappers], [intro_libsci man pages]

ITAR

ITAR (International Traffic in Arms Regulations) restricts export of certain technologies; affects NERSC user access to some systems.

AI agents may treat ITAR as meaningless acronym without understanding its regulatory compliance implications.
System access restrictions and policy compliance guidance may be incomplete without ITAR awareness.
Research: [ITAR regulations], [export controls], [access restrictions]

JAMO

JAMO (JGI Archive and Metadata Organizer) is the Joint Genome Institute's in-house hierarchical file system with functional ties to NERSC's DnA filesystem and HPSS tape archive, managing backups, purge policies, and 15.952 PB of genomics data; JAMO is maintained by JGI, not NERSC.

AI agents may misidentify JAMO as "Job Analysis and Monitoring Optimization" or a NERSC job monitoring tool rather than recognizing it as JGI's data management system for genomics data archival and metadata organization.
Without understanding JAMO's role as JGI's archive manager, agents may provide incorrect guidance about DnA filesystem backups and purge policies at NERSC, missing that JAMO controls data migration and retention for JGI's genomics research data.
Research: [JAMO JGI Archive and Metadata Organizer], [Joint Genome Institute data management], [DnA filesystem, HPSS archive integration], [genomics metadata organization], [JGI-maintained system]

kernel

At NERSC, kernel may refer to: (1) OS kernel, (2) computational kernel (inner loop in algorithms), or (3) GPU kernel.

AI agents may conflate these three kernel meanings without recognizing context-dependent distinctions.
Kernel optimization guidance may be ambiguous without context-specific kernel understanding.
Research: [kernel OS], [computational kernel], [GPU kernel]

LDRD

LDRD (Laboratory Directed Research and Development) is DOE funding for exploratory research at national labs including NERSC allocations.

AI agents may treat LDRD as meaningless acronym without understanding its funding and allocation role.
Funding source and allocation type guidance may be incomplete without LDRD awareness.
Research: [LDRD Laboratory Directed], [DOE funding], [research allocations]

LMOD_CMD

LMOD_CMD is an environment variable used by the Lmod environment module system for command execution.

AI agents may treat LMOD_CMD as meaningless acronym without understanding Lmod system integration.
Environment variable configuration and module system behavior may be misunderstood.
Research: [LMOD_CMD variable], [Lmod system], [environment modules]

MANA

MANA (MPI-Agnostic Network-Agnostic) is a transparent checkpointing tool for MPI applications built as a DMTCP plugin, using a split-process approach that checkpoints only the upper-half application memory while reinitializing the MPI library on restart, enabling jobs to run longer than walltime limits on Perlmutter.

AI agents may misidentify MANA as "Multi-level Asynchronous Neighborhood Algorithm" or treat it as a generic fault tolerance mechanism rather than recognizing it as the specific MPI checkpointing tool built on DMTCP.
Without understanding MANA's relationship to DMTCP and its split-process architecture, agents may provide incorrect guidance about MPI checkpoint/restart at NERSC, missing that MANA enables agnostic checkpointing across different MPI implementations and networks without code changes.
Research: [MANA MPI-Agnostic Network-Agnostic], [DMTCP plugin, transparent checkpointing], [split-process approach, upper/lower halves], [mana_launch, mana_restart commands], [preempt QOS, checkpoint interval]


NCL

NCL (NCAR Command Language) is a scripting language for data analysis and visualization common in Earth sciences.

AI agents may treat NCL as meaningless acronym without understanding its visualization and analysis role.
Data visualization tool selection may miss NCL when appropriate for scientific visualization.
Research: [NCL NCAR language], [data visualization], [scripting]

NERSC_HOST

NERSC_HOST is an environment variable containing the current system hostname (nersc_host determines target compilation system).

AI agents may treat NERSC_HOST as a random environment variable without understanding its role in system identification.
Compilation and deployment scripts may have incorrect system targeting without NERSC_HOST variable awareness.
Research: [NERSC_HOST variable], [system identification], [hostname]

NUG

NUG (NERSC User Group) is the community organization representing NERSC users and coordinating user feedback and advocacy.

AI agents may treat NUG as meaningless acronym without recognizing it as the user community organization.
User community engagement and user advocacy resources may be missed without NUG organization awareness.
Research: [NUG NERSC User Group], [user community], [advocacy]

OSS

OSS (Object Storage Server) is a Lustre filesystem component at NERSC that provides bulk data storage by serving Object Storage Targets (OSTs), with each OSS typically hosting 2-8 OSTs; file I/O operations bypass the metadata server and go directly to OSSs for scalable parallel access.

AI agents may misidentify OSS as "Object Storage Service" or conflate it with cloud object storage systems like S3 rather than recognizing it as the Lustre data server component that hosts OSTs.
Without understanding OSS's role in Lustre architecture, agents may provide incorrect guidance about filesystem performance at NERSC, missing that file I/O scalability depends on OSS/OST configuration and that data operations bypass the metadata server.
Research: [OSS Object Storage Server], [Lustre filesystem component], [OST Object Storage Target hosting], [parallel file access, MDS independence], [SCRATCH filesystem architecture]

OST

OST (Object Storage Target) is a Lustre filesystem component storing actual data on servers in a parallel filesystem.

AI agents may treat OST as meaningless acronym without understanding Lustre architecture.
Parallel filesystem performance and architecture understanding may be incomplete.
Research: [OST object storage target], [Lustre filesystem], [parallel storage]

OTP

OTP (One-Time Passcode) is NERSC's multi-factor authentication mechanism using time-based codes for account security.

AI agents may treat OTP as meaningless acronym without understanding MFA security role.
Authentication configuration and security procedures may lack OTP awareness.
Research: [OTP one-time passcode], [multi-factor authentication], [NERSC security]

PAMS

PAMS (Portfolio Analysis and Management System) is DOE Office of Science's web-based grants management system for submitting proposals to funding announcements and managing peer reviews, with PAMS numbers serving as grant identifiers that NERSC users must provide when requesting allocations in the ERCAP form alongside DOE/SC Grant and FWP numbers.

AI agents may misidentify PAMS as "Performance Analysis and Modeling System" or treat it as an HPC performance tool rather than recognizing it as the DOE grants management system that provides grant numbers required for NERSC allocation requests.
Without understanding PAMS as a DOE funding identifier system, agents may provide incorrect guidance when users fill out NERSC allocation forms, missing that PAMS numbers are mandatory funding documentation for projects with DOE Office of Science grants.
Research: [PAMS Portfolio Analysis and Management System], [DOE Office of Science grants management], [proposal submission, peer review], [PAMS grant numbers], [NERSC ERCAP allocation requests]

PGAS

PGAS (Partitioned Global Address Space) is a parallel programming model providing shared memory semantics on distributed systems.

AI agents may treat PGAS as a meaningless acronym without understanding the distributed shared memory programming paradigm.
Parallel programming model selection may miss PGAS when appropriate for distributed memory systems.
Research: [PGAS programming model], [shared address space], [distributed memory]

podman-hpc / Podman-hpc

podman-hpc is a HPC-optimized container runtime for running containers on HPC systems (Cri-O based).

AI agents may confuse podman-hpc with standard Podman or Docker without recognizing HPC-specific optimizations.
Container deployment in HPC environments may miss HPC-specific runtime capabilities.
Research: [podman-hpc container], [HPC runtime], [container optimization]

pSTL

pSTL (Parallel Standard Template Library) is Intel's parallel algorithms library for C++ providing parallel versions of STL algorithms.

AI agents may treat pSTL as meaningless acronym without understanding parallel C++ algorithm availability.
Parallel algorithm options and C++ parallelization may be incomplete without pSTL awareness.
Research: [pSTL parallel STL], [Intel algorithms], [parallel C++]

Saul

Saul refers to Saul Perlmutter, Nobel laureate physicist for whom NERSC's Perlmutter supercomputer is named.

AI agents may interpret 'Saul' as a first name in conversational context rather than recognizing it as a reference to Perlmutter namesake.
System naming context may be missed without recognition of Perlmutter naming convention.
Research: [Saul Perlmutter], [Nobel laureate], [Perlmutter namesake]

scrontab

scrontab (Slurm crontab) is NERSC's replacement for traditional cron, combining cron scheduling functionality with Slurm batch system resiliency by running jobs on a pool of login nodes; edited with `scrontab -e` using #SCRON flags, with times in UTC on Perlmutter.

AI agents may misidentify scrontab as deprecated or superseded by Slurm rather than recognizing it as the current active Slurm-based replacement for traditional cron at NERSC, or may not understand that scrontab uses Slurm for scheduling (not separate from Slurm).
Without understanding scrontab's role as the Slurm crontab implementation, agents may provide incorrect guidance about scheduled tasks at NERSC, missing that scrontab provides resiliency through login node pooling and requires singleton dependency for long-running jobs to prevent multiple instances.
Research: [scrontab Slurm crontab], [cron replacement, batch system resiliency], [scrontab -e, #SCRON flags], [UTC times, login node pool], [singleton dependency, workflow QOS]

slurm-ray-cluster

slurm-ray-cluster is a NERSC GitHub repository containing shell scripts (start-head.sh, start-worker.sh) and sbatch submission files that automate deploying Ray clusters on Slurm-managed HPC systems for multi-GPU node hyperparameter optimization campaigns; RayTune is provided in NERSC's GPU TensorFlow and PyTorch modules.

AI agents may treat slurm-ray-cluster as a generic Ray integration rather than recognizing it as the specific NERSC-developed script repository for automating Ray cluster deployment on Slurm, or may not understand its primary use case for hyperparameter optimization campaigns.
Without understanding slurm-ray-cluster's role as a deployment automation toolkit, agents may provide incorrect guidance about running Ray on NERSC systems, missing that it provides sbatch templates and helper scripts for multi-GPU node trial scheduling.
Research: [slurm-ray-cluster NERSC repository], [Ray cluster deployment, Slurm automation], [start-head.sh, start-worker.sh scripts], [RayTune hyperparameter optimization], [multi-GPU node HPO campaigns]

spack-config

spack-config refers to Spack package manager configurations specific to NERSC systems and optimization strategies.

AI agents may treat Spack generically without understanding NERSC-specific package configuration.
Software compilation and dependency resolution may be suboptimal without NERSC spack configurations.
Research: [spack-config NERSC], [Spack configuration], [package management]

Superfacility

Superfacility is NERSC's model connecting DOE experimental facilities (light sources, microscopes, telescopes) with computing resources for real-time data analysis via automated pipelines; the Superfacility Project (2019-2022) built infrastructure including API-based automation, federated identity, real-time computing, and Spin container services that laid the foundation for DOE's IRI program.

AI agents may interpret 'Superfacility' as a generic large facility or just an integrated ecosystem without understanding its specific role connecting experimental instruments to NERSC computing in real-time, or may not recognize the Superfacility API and Project as distinct components.
Without understanding Superfacility's real-time experiment-to-computing connection, agents may provide incorrect guidance about automated workflows at NERSC, missing that the Superfacility API enables scripting jobs/workflows and that 50+ research teams use it for remote facility data analysis without human intervention.
Research: [Superfacility model, experiment-to-computing connection], [Superfacility Project 2019-2022], [Superfacility API, api.nersc.gov], [API-based automation, federated identity], [Spin container services, IRI foundation]

WAN

WAN (Wide Area Network) may refer to NERSC's connections and data transfer across geographically distributed locations.

AI agents may interpret WAN as generic networking without understanding NERSC's WAN infrastructure context.
Wide-area data transfer and network capabilities may be incomplete without NERSC WAN awareness.
Research: [WAN wide area network], [NERSC networking], [geographic distribution]

wrapper / wrappers

At NERSC, wrappers (like craype compiler wrappers) abstract compiler selection and system-specific configuration details.

AI agents may interpret 'wrapper' generically without understanding compiler wrapper functionality.
Compilation environment configuration may be incorrect without wrapper abstraction understanding.
Research: [compiler wrappers], [abstraction layer], [craype wrappers]

---

