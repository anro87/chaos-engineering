# Chaos-Engineering Use Case

<img src="https://user-images.githubusercontent.com/36228512/165265277-9fb355ee-fcf6-44fd-a1af-a12de651ed5d.jpeg" alt="drawing" align="left" style="width:400px;"/>
This repository contains a Chaos-Engineering use case with the coding in folder infrastructure to initialize the test environment 
and Chaos-Engineering experiments in folder chaos-monkey, with all logic to test the different outage scenarios. 


# Tools
All Chaos-Engineering experiments are based on the  [https://chaostoolkit.org/](ChaosToolkit).
The Infrastructure setup is done via Terraform

# System under Chaos
The chaos experiments are running against an AWS hosted CRM-Service. The system provides a RESTful API interface to fetch all available customers and related projects. Moreover available Sales-Leads are fetched from another external API and processed before returned to the API caller.

![Architektur drawio](https://user-images.githubusercontent.com/36228512/165273451-7e245c9a-e07b-40f0-9575-4640617b5494.png)

# Executed Experiments

1. Does the service tolerate a database restart?
2. Does the service tolerate a EC2 instance restart?
3. Does the service tolerate network hiccups on external API?
4. Does the service tolerate problems while S3 file is removed?
5. Does the service tolerate a timeout while fetching data from AWS Lambda function?

# Setup environment
```console
foo@bar:~$ cd /infrastructure
foo@bar:~$ sh build_deploy.sh
```

The script will prompt for DB-user + password and API-user + password. Password will be hidden.
Once done, a API-Token will be printed that is valid for 2 hours.

# Executed Experiments

```console
foo@bar:~$ cd /chaos-monkey
foo@bar:~$ sh exec_experiment.sh
```

The script will execute all experiments mentioned above and create a report pdf at `./chaos-monkey/report.pdf`.
