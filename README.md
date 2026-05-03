# 🚀 Full Stack Spring Boot & React (Professional)

> A full-stack web application built with **Spring Boot** on the backend and **React.js** on the frontend, containerized with Docker, deployed on AWS, and automated with GitHub Actions CI/CD.

---

## 📑 Table of Contents

- [Software Architecture](#-software-architecture)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Build & Packaging](#-build--packaging)
- [Docker & Jib](#-docker--jib)
- [Database Setup](#-database-setup)
- [AWS Deployment](#-aws--elastic-beanstalk-deployment)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Testing](#-unit--integration-testing)
- [React Project Structure](#-react-project-structure)
- [Command Cheat Sheet](#-command-cheat-sheet)
- [Resources & Links](#-resources--links)

---

## 🏗 Software Architecture

!["Software Architecture Image"](./resources/architecture.jpg)

### Architecture Layers

| Layer | Technology |
|---|---|
| Backend API | Spring Boot 2.7.6 |
| Frontend | React.js (Hooks & Functional Components) |
| Build Tool | Maven (Maven Wrapper `./mvnw`) |
| Database | PostgreSQL on Docker / AWS RDS |
| ORM | Spring Data JPA |
| Containerization | Docker + Jib |
| Cloud Deployment | AWS Elastic Beanstalk + RDS |
| CI/CD | GitHub Actions |
| Monitoring | Slack Notifications |
| Testing | JUnit 5, AssertJ, H2 In-memory DB |

---

## 🛠 Tech Stack

### Backend
- **Spring Boot** — REST API, Validation, Data JPA
- **PostgreSQL** — Production database (Docker locally, RDS on AWS)
- **Lombok** — Reduces boilerplate Java code
- **Java Faker** — Generates fake data for integration tests
- **H2** — In-memory database used during testing

### Frontend
- **React.js** — Functional components with Hooks (`useState`, `useEffect`)
- **Ant Design** — Enterprise-level UI component library
- **React Bootstrap** — Bootstrap-based UI components
- **Axios / Unfetch** — HTTP clients for calling the backend API

### DevOps & Infrastructure
- **Maven Profiles** — Bundle FE+BE, build Docker images, push to DockerHub
- **Jib** — Builds optimized Docker images without a Docker daemon
- **Docker Compose** — Multi-container local setup
- **AWS Elastic Beanstalk** — Application hosting with auto-scaling and load balancing
- **GitHub Actions** — CI/CD automation (build, test, deploy)
- **Slack** — Deployment notifications

---

## ⚡ Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Java | 11 |
| Maven | via `./mvnw` wrapper |
| Node.js | v14.21.1 |
| npm | 6.14.17 |
| Docker | Latest |
| PostgreSQL | via Docker (`postgres:alpine`) |

### Run Locally

**1. Start the database:**
```bash
docker network create db
docker run --name db -p 5432:5432 --network=db \
  -v "$PWD:/var/lib/postgresql/data" \
  -e POSTGRES_PASSWORD=password \
  -d postgres:alpine
```

**2. Run the backend:**
```bash
./mvnw clean install
java -jar target/spring-boot-full-stack-professional-0.0.1-SNAPSHOT.jar
```

**3. Run the frontend (separately in development):**
```bash
cd src/frontend
npm install
npm start
# or on a specific host:
HOST=0.0.0.0 npm start
```

The backend runs on `http://localhost:8080` and the frontend on `http://localhost:3000`.

---

## 📦 Build & Packaging

Instead of running the backend and frontend separately, you can bundle them into a **single JAR file** using Maven.

### How It Works

1. Maven runs `npm install` and `npm run build` via the `frontend-maven-plugin`
2. The React `./build` directory is copied into the Spring Boot `./resources/static` directory via `maven-resources-plugin`
3. A single JAR file is generated in `./target/`

### Maven Profiles

| Profile | Command | Description |
|---|---|---|
| `bundle-backend-and-frontend` *(default)* | `./mvnw clean install` | Builds FE + BE into one JAR |
| `jib-build-docker-image-and-push-it-to-docker-hub` | see below | Builds JAR + Docker image + pushes to DockerHub |
| `jib-build-local-docker-image` | see below | Builds JAR + local Docker image |

```bash
# Show all active profiles
./mvnw help:active-profiles

# Bundle FE+BE and push to DockerHub
./mvnw clean install -P bundle-backend-and-frontend \
  -P jib-build-docker-image-and-push-it-to-docker-hub \
  -Dapp.image.tag=1

# Bundle FE+BE and create local Docker image
./mvnw clean install -P bundle-backend-and-frontend \
  -P jib-build-local-docker-image \
  -Dapp.image.tag=latest
```

---

## 🐳 Docker & Jib

[Jib](https://github.com/GoogleContainerTools/jib) builds optimized Docker and OCI images for Java applications **without requiring a Docker daemon**.

### Build Docker Images with Jib

```bash
# Build local Docker image (JAR must already exist)
./mvnw jib:dockerBuild -Djib.to.image=fullstack:v1

# Build local Docker image (also creates JAR first)
./mvnw clean install jib:dockerBuild -Djib.to.image=fullstack:v1

# Build and push to DockerHub
./mvnw clean install jib:build -Djib.to.image=bdostumski/spring-react-fullstack:v1

# Build and push to DockerHub with explicit credentials
./mvnw clean install jib:build \
  -Djib.to.image=bdostumski/spring-react-fullstack:latest \
  -Djib.to.auth.username=bdostumski \
  -Djib.to.auth.password=my-secret-password
```

### Common Docker Commands

```bash
# Images
docker image ls               # list images
docker image rm name:tag      # delete image
docker pull image:version     # pull image from remote

# Containers
docker ps                     # show running containers
docker ps -a                  # show all containers
docker rm -f container_name   # force remove running container

# Run
docker run --name fullstack -p 8080:8080 fullstack:v1
docker run --rm -p 8080:8080 bdostumski/springboot-react-fullstack:latest

# Auth
docker login
```

---

## 🗄 Database Setup

### Local PostgreSQL via Docker

```bash
# 1. Create a Docker network
docker network create db

# 2. Run Postgres container
docker run --name db -p 5432:5432 --network=db \
  -v "$PWD:/var/lib/postgresql/data" \
  -e POSTGRES_PASSWORD=password \
  -d postgres:alpine

# 3. Connect to the database interactively
docker run -it --rm --network=db postgres:alpine psql -h db -U postgres

# 4. Remove network when done
docker network rm db
```

> ℹ️ This local setup is for development/testing. Production uses **AWS RDS**.

### Connect to AWS RDS via Docker

```bash
docker run -it --rm postgres:alpine psql \
  -h aa9320n4muma7h.celswdmxhcr1.eu-west-1.rds.amazonaws.com \
  -U syscomz -d postgres
```

> **Note:** To connect externally, configure the RDS Security Group to allow your IP address as an inbound rule.

### Spring Profiles for DB Config

Create `application-dev.properties` and set the environment variable:
```
SPRING_PROFILES_ACTIVE=dev
```

---

## ☁️ AWS & Elastic Beanstalk Deployment

### Architecture Overview

![AWS Environments](./resources/aws-environments.png)

Elastic Beanstalk automatically provisions:
- **Load Balancer** — distributes incoming traffic
- **Auto-Scaling** — adjusts EC2 instances based on load
- **EC2** — actual virtual servers running the application
- **ECS Cluster** — container orchestration

### Deployment Steps

1. Remove the `SPRING_PROFILES_ACTIVE=dev` environment variable from your IDE
2. Login to Docker: `docker login`
3. Build and push the image:
   ```bash
   ./mvnw clean install \
     -P bundle-backend-and-frontend \
     -P jib-build-docker-image-and-push-it-to-docker-hub \
     -Dapp.image.tag=3
   ```
4. Upload `./elasticbeanstalk/docker-compose.yaml` to your Elastic Beanstalk environment

![AWS Deployed Application](./resources/aws-deployed-application.png)

### AWS RDS Setup

1. In Elastic Beanstalk → Configuration → Database → select PostgreSQL (`db.t2.micro`)
2. To allow external connections: go to RDS → DB Instances → your instance → Security → modify the Security Group inbound rules

![AWS ElasticBean Stalk Config DB](./resources/aws-configure-database.png)
![AWS RDS](./resources/aws-rds.png)
![AWS RDS Screen](./resources/aws-rds-screen.png)
![AWS RDS VCP Screen](./resources/aws-rds-vcp-screen.png)
![AWS RDS add Inbounded Rules](./resources/aws-rds-add-inbounded-rules.png)
![AWS RDS external connection](./resources/aws-rds-external-connection.png)

> 💡 To avoid AWS charges, **terminate** the environment when not in use and **restore** it when needed.

---

## 🔄 CI/CD Pipeline

![Github Actions](./resources/github-actions.png)

### Overview

```
Push Code → GitHub Actions
                ├── Pull Request → BUILD WORKFLOW (CI)
                └── Merge to Main → DEPLOYMENT WORKFLOW (CI/CD)
```

### 1. Pull Request → BUILD WORKFLOW (CI)

Triggered on every pull request. Runs on Ubuntu runner.

| Step | Action |
|---|---|
| 1 | Checkout code |
| 2 | Setup Java |
| 3 | Setup PostgreSQL |
| 4 | `mvn clean package` (build + compile + run all tests) |
| 5 | ✅ "OK TO MERGE" status — reviewer can approve and merge |

### 2. Merge to Main → DEPLOYMENT WORKFLOW (CI/CD)

Triggered when a PR is merged into `main`. Runs on Ubuntu runner.

| Step | Action |
|---|---|
| 1 | 📣 Slack: *"CI/CD is ongoing..."* |
| 2 | Checkout code |
| 3 | Setup Java |
| 4 | Generate build number (e.g. `1.0.1`) |
| 5 | Docker login to DockerHub |
| 6 | `mvn clean package` + Jib build image |
| 7 | 📣 Slack: *"Pushed bdostumski/image-name:1.0.1 to Docker Hub"* |
| 8 | Update `docker-compose.yaml` in Elastic Beanstalk |
| 9 | 📣 Slack: *"Deployment started..."* |
| 10 | Deploy to AWS |
| 11 | 📣 Slack: *"The new app is up and running!"* |

> ⚠️ If any step fails, the workflow stops at that step and does not continue.

### Slack Setup

1. Go to [api.slack.com/apps](https://api.slack.com/apps) → **Create App** → **From scratch**
2. Enable **Incoming Webhooks** → **Add New Webhook to Workspace** → select channel → **Allow**
3. Copy the Webhook URL and add it as a GitHub repository secret
4. Add DockerHub credentials and AWS credentials as GitHub repository secrets

#### AWS IAM for Automated Deployment

1. In AWS Console → **IAM** → **User Groups** → create group with `AdministratorAccess-AWSElasticBeanStalk` policy
2. Create a new user → assign to the group → generate **Access Key** (Programmatic access)
3. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as GitHub repository secrets

### CI/CD Slack Notification Screenshots

![CICD ongoing](./resources/cicd-message1.png)
![CICD pushed to docker hub](./resources/cicd-message2.png)
![Elastic Beanstalk Deployment started](./resources/cicd-message3.png)
![Deployed to AWS](./resources/cicd-message4.png)

---

## 🧪 Unit / Integration Testing

!["Testing UML Diagram"](./resources/unit_testing_uml_diagram.png)

> Testing flows from the **repository layer → service layer**. Each layer mocks the units already tested below it.

### JUnit 5

JUnit 5 = **JUnit Platform** + **JUnit Jupiter** + **JUnit Vintage**

| Component | Description |
|---|---|
| JUnit Platform | Foundation for launching testing frameworks on the JVM |
| JUnit Jupiter | New programming model and extension model for writing tests in JUnit 5 |
| JUnit Vintage | Provides a TestEngine for running JUnit 3 & JUnit 4 based tests |

### Tools

| Tool | Purpose |
|---|---|
| **AssertJ** | Rich assertions, helpful error messages, better readability than JUnit 5 assertions |
| **H2 In-memory Database** | Used as the test database (no real DB needed) |
| **Java Faker** | Generates random fake data for integration tests |
| **Failsafe Plugin** | Runs integration tests (Surefire runs unit tests) |

### Strategy

- **Unit Tests** — test all positive and negative paths per layer; mock dependencies from lower layers
- **Integration Tests** — test positive paths only (negative cases already covered by unit tests)

---

## 📂 React Project Structure

### Main Folder

| Path | Type | Description |
|---|---|---|
| `./node_modules` | Folder | All npm dependencies |
| `./.gitignore` | File | Files intentionally untracked by Git |
| `./package.json` | File | Project metadata and dependency list |
| `./README.md` | File | Project documentation (this file) |
| `./yarn.lock` | File | Ensures consistent dependency versions across machines |

### Public Folder

| Path | Type | Description |
|---|---|---|
| `./public` | Folder | Root folder served as the React app |
| `./public/favicon.ico` | File | App icon used in `index.html` |
| `./public/index.html` | File | Template file served when app starts |
| `./public/logo192.png`, `logo512.png` | Files | React logos (192×192 and 512×512 px) |
| `./public/manifest.json` | File | App metadata for PWA / mobile home-screen |
| `./robots.txt` | File | Rules for web crawlers and scrapers |

### Src Folder

| Path | Type | Description |
|---|---|---|
| `./src` | Folder | Core React application code |
| `./src/App.css` | File | Styles for `App.js` component |
| `./src/App.js` | File | Root React component |
| `./src/App.test.js` | File | Basic test for the root component (Jest) |
| `./src/index.css` | File | Global app styles |
| `./src/index.js` | File | Renders root component and registers service workers |
| `./src/logo.svg` | File | SVG React logo |
| `./src/serviceWorker.js` | File | Pre-caches scripts to improve performance |
| `./src/setupTests.js` | File | Sets up and invokes tests via `npm run test` |

### Key React Concepts Used

- **`useState` Hook** — tracks state (data/properties) in functional components
- **`useEffect` Hook** — performs side effects: fetching data, updating the DOM, timers
- **Axios / Unfetch** — HTTP clients for fetching data from the Spring Boot backend

---

## 📜 Command Cheat Sheet

### npm

| Command | Description |
|---|---|
| `npm install` | Install all dependencies from `package.json` into `node_modules` |
| `npm install --save [dependency@version]` | Install a new dependency |
| `npm run build` | Build the FE application (creates `./build` directory) |
| `npm start` | Start the FE development server |
| `HOST=0.0.0.0 npm start` | Start FE on a specific host |
| `npm -g i npx` | Install `npx` globally |
| `npx create-react-app frontend` | Create a new React app |
| `npx create-react-app@4.0.3 frontend` | Create React app with a specific version |
| `npm install --save antd@4.13.0` | Install Ant Design with a specific version |
| `npm i -S unfetch` | Install Unfetch |
| `npm install --save @ant-design/icons` | Install Ant Design icons |

### Java

| Command | Description |
|---|---|
| `java -jar file.jar` | Run a JAR file from the `./target` folder |

### Maven (`./mvnw`)

| Command | Description |
|---|---|
| `./mvnw clean` | Delete the `./target` folder |
| `./mvnw install` | Create `./target` folder and build the project using the active profile |
| `./mvnw clean install` | Combine clean + install |
| `./mvnw help:active-profiles` | Show all active Maven profiles |

### Docker & Jib

| Command | Description |
|---|---|
| `docker login` | Login to Docker Hub |
| `docker image ls` / `docker images` | Show all local images |
| `docker ps` | Show running containers |
| `docker ps -a` | Show all containers |
| `docker rm -f container` | Force remove a running container |
| `docker run --name name -p 8080:8080 image:version` | Run a container |
| `docker run --rm --name name -p 8080:8080 image:version` | Run and auto-remove when stopped |
| `docker pull image:version` | Pull an image from a remote repository |
| `./mvnw jib:dockerBuild -Djib.to.image=name:version` | Build a local Docker image with Jib |
| `./mvnw clean install jib:dockerBuild -Djib.to.image=name:version` | Build JAR then local Docker image |
| `./mvnw clean install jib:build -Djib.to.image=bdostumski/name:v1` | Build and push to DockerHub |

### Docker & Databases

```bash
docker network create db
docker network rm db
docker run --name db -p 5555:5432 --network=db \
  -v "/path/to/database-dir:/var/lib/postgresql/data" \
  -e POSTGRES_PASSWORD=password \
  -d postgres:alpine
docker run -it --rm --network=db postgres:alpine psql -h db -U postgres
docker run -it --rm postgres:alpine psql \
  -h aa9320n4muma7h.celswdmxhcr1.eu-west-1.rds.amazonaws.com \
  -U amigoscode -d postgres
```

---

## 🔗 Resources & Links

### Frameworks & Libraries

| Resource | Description |
|---|---|
| [Spring Framework](https://spring.io/projects/spring-framework) | Application framework and IoC container for Java |
| [Spring Initializr](https://start.spring.io/) | Spring project generator |
| [React.js](https://reactjs.org/) | JavaScript library for building UIs |
| [Node.js](https://nodejs.org/en/) | Open-source JavaScript runtime environment |
| [Create React App (npm)](https://www.npmjs.com/package/create-react-app) | CRA on npm |
| [Create React App (GitHub)](https://github.com/facebook/create-react-app) | CRA repository |
| [Ant Design](https://ant.design/) | UI design system for enterprise-level products |
| [Ant Design + CRA](https://ant.design/docs/react/use-with-create-react-app) | Using Ant Design with Create React App |
| [React Bootstrap](https://react-bootstrap.github.io/) | Bootstrap components for React |
| [Unfetch](https://github.com/developit/unfetch) | Minimal 500b fetch polyfill |
| [Axios](https://github.com/axios/axios) | Promise-based HTTP client for browser and Node.js |
| [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) | Cross-Origin Resource Sharing explained |

### Build & DevOps

| Resource | Description |
|---|---|
| [frontend-maven-plugin](https://github.com/eirslett/frontend-maven-plugin) | Automates bundling FE and BE projects into one |
| [maven-resources-plugin](https://maven.apache.org/plugins/maven-resources-plugin/dependency-info.html) | Copies `./build` from FE into `./resources/static` in BE |
| [Docker Hub](https://hub.docker.com/) | Docker container registry |
| [Jib](https://github.com/GoogleContainerTools/jib) | Containerize Java apps without Docker daemon |
| [Jib FAQs](https://github.com/GoogleContainerTools/jib/blob/master/docs/faq.md#what-should-i-do-when-the-registry-responds-with-unauthorized) | Fixes for common Jib issues |
| [Docker Compose](https://docs.docker.com/compose/) | Tool for defining and running multi-container apps |
| [Docker Compose v3 Reference](https://docs.docker.com/compose/compose-file/compose-file-v3/) | Compose file version 3 spec |
| [Draw.io](https://app.diagrams.net/) | Diagramming tool |

### AWS

| Resource | Description |
|---|---|
| [AWS Free Tier](https://aws.amazon.com/free/) | AWS registration and free tier |
| [Terminate Elastic Beanstalk Environment](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.terminating.html) | How to terminate an EB environment |
| [Restore Elastic Beanstalk Environment](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environment-management-rebuild.html) | How to restore a terminated EB environment |
| [Docker Image: Postgres](https://hub.docker.com/_/postgres) | Official Postgres image on Docker Hub |

### CI/CD & Testing

| Resource | Description |
|---|---|
| [GitHub Actions](https://github.com/features/actions) | Automate your workflow from idea to production |
| [Slack](https://slack.com/) | Team messaging system |
| [Slack Incoming Webhooks](https://api.slack.com/apps) | Build your own Slack app for notifications |
| [Slack Webhook Guide](https://www.svix.com/resources/guides/how-to-get-slack-webhook-url/) | Fix for Slack message issues |
| [Mockaroo](https://www.mockaroo.com/) | Generate fake data based on production data |
| [JUnit 5](https://junit.org/junit5/docs/current/user-guide/#writing-tests-parameterized-tests) | Testing framework for Java and the JVM |
| [AssertJ](https://assertj.github.io/doc/) | Fluent assertion library for Java |
| [H2 Database](https://www.h2database.com/html/main.html) | In-memory database for testing |
| [Failsafe Plugin](https://maven.apache.org/surefire/maven-failsafe-plugin/) | Maven plugin for running integration tests |
| [Java Faker](https://github.com/DiUS/java-faker) | Generates random fake data for tests |

---

> 📝 *This project was built as part of a professional full-stack learning course covering Spring Boot, React, Docker, AWS, and CI/CD automation.*s
