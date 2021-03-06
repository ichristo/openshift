
Table of Contents
---

<!-- TOC depthFrom:undefined depthTo:undefined withLinks:1 updateOnSave:1 orderedList:0 -->

- [Login to OpenShift](#login-to-openshift)
- [Docker, kubernetes guestbook, 3.1](#docker-kubernetes-guestbook-31)
- [Docker, project with WAR, 3.1](#docker-project-with-war-31)
- [Kitchensink with just WAR file, 3.1](#kitchensink-with-just-war-file-31)
- [Kitchensink standalone S2I, H2 database, builder image, 3.1](#kitchensink-standalone-s2i-h2-database-builder-image-31)
- [Kitchensink S2I, postgres, builder image, 3.1](#kitchensink-s2i-postgres-builder-image-31)
- [Ticket Monster demo to prod with template, 3.1](#ticket-monster-demo-to-prod-with-template-31)
- [AB Deployment Testing, 3.1](#ab-deployment-testing-31)
- [MLB Parks app and db, create app and add db, 3.1](#mlb-parks-app-and-db-create-app-and-add-db-31)
- [MLB Parks app and db, template, 3.1](#mlb-parks-app-and-db-template-31)
- [PHP, persistent volumes, 3.1](#php-persistent-volumes-31)
- [Ruby hello-world with db different project, Ruby Instant App, 3.0](#ruby-hello-world-with-db-different-project-ruby-instant-app-30)
- [Ruby hello-world with db different project, 3.0](#ruby-hello-world-with-db-different-project-30)
- [PHP Upload Application Template, Instant App, 3.0](#php-upload-application-template-instant-app-30)
- [PHP Upload Application, Instant App, 3.0](#php-upload-application-instant-app-30)
- [References](#references)

<!-- /TOC -->

# Login to OpenShift 

	oc login ose-aio.example.com:8443 --certificate-authority=ca.crt -u <username> -p <password>

# Docker, kubernetes guestbook, 3.1
Last Tested: 3.1
Added: 2016-01-21

Console -  As User  
Create new project & application  

	oc new-project guestbook
	oc new-app kubernetes/guestbook
	oc get pods -w
	
Wait for the application to finish deploying  

	NAME                 READY     STATUS    RESTARTS   AGE
	guestbook-1-deploy   0/1       Pending   0          11s

When the pod is running

	NAME                READY     STATUS    RESTARTS   AGE
	guestbook-1-fge2d   1/1       Running   0          34s

A service is created, but a route needs to be added for external access  

	NAME        CLUSTER_IP      EXTERNAL_IP   PORT(S)    SELECTOR                                   AGE
	guestbook   172.30.27.215   <none>        3000/TCP   app=guestbook,deploymentconfig=guestbook   1m
	
Create the route

	oc expose service guestbook
	oc get route

	NAME        HOST/PORT                                   PATH      SERVICE     LABELS          INSECURE POLICY   TLS TERMINATION
	guestbook   guestbook-guestbook.cloudapps.example.com             guestbook   app=guestbook

Browser - navigate to  

	http://guestbook-guestbook.cloudapps.example.com
 
# Docker, project with WAR, 3.1
Last Tested: 3.1  
b6m  

Console - As User  
 
	oc new-project k-docker
	oc new-app https://github.com/kenthua/kitchensink-docker.git
	oc get pods -w

You will get an error like this because the image hasn't been pulled down yet

	NAME                         READY     REASON                                                     RESTARTS   AGE
	kitchensink-docker-1-build   1/1       Running                                                    0          1m
	kitchensink-docker-1-e2so4   0/1       Error: image library/kitchensink-docker:latest not found   0          1m

Watch the docker build

	oc logs -f kitchensink-docker-1-build
	
	I0717 18:11:44.001404       1 docker.go:91] Successfully pushed 172.30.56.67:5000/k-docker/kitchensink-docker	

Expose the service

	oc get service
	oc expose service kitchensink-docker
	browser (http://kitchensink-docker.k-docker.cloudapps.example.com)	

# Kitchensink with just WAR file, 3.1
Last Tested: 3.1 
b5m  

Console - As User  

	oc new-project k-war

Browser - Add to Project

	jboss-eap64-openshift:1.1 or eap64-basic-s2i
	Git repository URL: https://github.com/kenthua/kitchensink-war.git

or command line  

	oc new-app --template=eap64-basic-s2i -p SOURCE_REPOSITORY_URL=https://github.com/kenthua/kitchensink-war.git,SOURCE_REPOSITORY_REF=master,CONTEXT_DIR="",APPLICATION_NAME=kitchensink-war

	oc get pod
	oc logs -f kitchensink-war-1-build

Browser - Browse -> Services -> Routes:

OR command line

	oc get route

URL

	http://kitchensink-war.k-war.cloudapps.example.com	


# Kitchensink standalone S2I, H2 database, builder image, 3.1
Last Tested: 3.1  
b6m  

Console -  As User  

	oc new-project kitchensink

Browser - Add to Project

	jboss-eap64-openshift:1.1 or eap64-basic-s2i
	Git repository URL: https://github.com/kenthua/kitchensink.git

or command line

	oc new-app --template=eap64-basic-s2i -p SOURCE_REPOSITORY_URL=https://github.com/kenthua/kitchensink.git,SOURCE_REPOSITORY_REF=master,CONTEXT_DIR="",APPLICATION_NAME=kitchensink

Watch the build when it starts

	oc get build -w
	NAME            TYPE      STATUS    POD
	kitchensink-1   Source    New       kitchensink-1-build
	kitchensink-1   Source    Pending   kitchensink-1-build
	kitchensink-1   Source    Running   kitchensink-1-build

Watch builds from the build option or builder pod (pom.xml in src, maven build is exected)

	oc build-logs kitchensink-1
	oc logs -f kitchensink-1-build

Browser

	http://kitchensink.kitchensink.cloudapps.example.com


# Kitchensink S2I, postgres, builder image, 3.1
Last Tested: 3.1 
b8m  

Browser - New Project

	k-postgres

Add EAP keystore secret

	oc project k-postgres
	oc create -f https://raw.githubusercontent.com/kenthua/openshift/master/configs/user/eap-app-s2i-secret.json
 
Browser - Add to Project

	eap64-postgresql-s2i	
	Name: eap-app
	SOURCE_REPOSITORY_URL=https://github.com/kenthua/kitchensink-postgres.git 
	SOURCE_REPOSITORY_REF=master
	CONTEXT_DIR=
	DB_JNDI=java:jboss/datasources/PostgreSQLDS

Browser - Check overview page  

Check out the pods for completion (notice the postgres pod as well)

	oc get pod
	
	NAME                         READY     STATUS      RESTARTS   AGE
	eap-app-1-build              0/1       Completed   0          2m
	eap-app-1-uiazy              1/1       Running     0          45s
	eap-app-postgresql-1-bkruh   1/1       Running     0          2m

Once the build is complete and running, let's manually scale

	oc get rc
	
	CONTROLLER             CONTAINER(S)         IMAGE(S)                                                                                                       SELECTOR                                                                                                  REPLICAS   AGE
eap-app-1              eap-app              172.30.18.39:5000/k-postgres/eap-app@sha256:3d1e4704939eb530a1283bdcc718c008a50faadf89b4d75f3874d985193c05ed   deployment=eap-app-1,deploymentConfig=eap-app,deploymentconfig=eap-app                                    1          1m
eap-app-postgresql-1   eap-app-postgresql   registry.access.redhat.com/openshift3/postgresql-92-rhel7:latest                                               deployment=eap-app-postgresql-1,deploymentConfig=eap-app-postgresql,deploymentconfig=eap-app-postgresql   1          2m
	
	oc scale --replicas=2 rc/eap-app-1
	
	oc get pod
	
	NAME                         READY     STATUS      RESTARTS   AGE
	eap-app-1-autqo              1/1       Running     0          27s
	eap-app-1-build              0/1       Completed   0          3m
	eap-app-1-uiazy              1/1       Running     0          2m
	eap-app-postgresql-1-bkruh   1/1       Running     0          3m
	
	
	oc get service eap-app
	
	NAME      CLUSTER_IP       EXTERNAL_IP   PORT(S)    SELECTOR                   AGE
	eap-app   172.30.126.247   <none>        8080/TCP   deploymentConfig=eap-app   3m
	
		
	oc describe service eap-app

	Name:			eap-app
	Namespace:		k-postgres
	Labels:			application=eap-app,template=eap64-postgresql-s2i,xpaas=1.1.0
	Selector:		deploymentConfig=eap-app
	Type:			ClusterIP
	IP:			172.30.126.247
	Port:			<unnamed>	8080/TCP
	Endpoints:		10.1.0.8:8080,10.1.1.21:8080
	Session Affinity:	None
	No events.

# Ticket Monster demo to prod with template, 3.1
Last Tested: 3.1.0  
Added: 2016-01-20  

Scenario derived from Jim Minter, thanks Jim!  

Console -  As `system:admin`
Create 2 projects, `demo` and `prod`, add policy for prod to be able to pull images from the `demo` project

	oadm new-project demo --admin=alice
	oadm new-project prod --admin=alice
	oc policy add-role-to-group system:image-puller system:serviceaccounts:prod -n demo
	
Add templates to both the openshift namespace  

	oc create -n openshift -f https://raw.githubusercontent.com/kenthua/openshift/master/demo/config/ticket-monster-prod-template.yaml
	oc create -n openshift -f https://raw.githubusercontent.com/kenthua/openshift/master/demo/config/ticket-monster-template.yaml

Browser - select project `demo`

Browser - Add to Project (filter by keyword 'monster')

	monster

Force deployment of monster-mysql (if mysql deploys after the monster build is done, you must re-deploy monster)  
Browser - Deployments - `monster-mysql` - Deploy

Browser - navigate to 

	http://monster-demo.cloudapps.example.com
	
Browser - Projects (Home View)  

Browser - select project `prod`

Browser - Add to Project (filter by keyword 'monster')

	monster-prod

Force deployment of monster-mysql    
Browser - Deployments - `monster-mysql` - Deploy  

Console - As User   
Tag the demo project monster imagestream as prod  
From the imagestream `monster`, extract the latest PullSpec from `monster@sha256....`  
As User: alice

	oc project demo
	export MY_TAG=`oc describe is monster | grep latest | awk '{split($6, a, /\/demo\//); print a[2]}'`
	oc tag $MY_TAG monster:prod
	oc describe is monster
	
The deployment `monster` in the project `prod` should automatically trigger and build

Browser - navigate to

	http://monster-prod.cloudapps.example.com
	
# AB Deployment Testing, 3.1
Last Tested: 3.1.0  
Added: 2015-09-22 

Reference, thanks to Veer for the example on the OpenShift blog: https://blog.openshift.com/openshift-3-demo-part-11-ab-deployments/

Browser - New Project

	ab-example
	
Browser - Add to Project  
Click Show advanced build and deployment options, for more options  
NOTE: We do not want to create a route because we will be creating a new service and a new route based on the service  

	php:5.5
	Name: a-example
	https://github.com/kenthua/ab-example.git
	Routing: Create a route to the application: No
	Labels: abgroup=true  
	
Then we will expose the DC as a service called ab-service with a selector of abgroup=true	
	
	oc expose dc/a-example --name=ab-service --selector=abgroup=true --generator=service/v1
	
Expose the service as a route
	
	oc expose service ab-service
	
Increase the replicas to 4

	oc scale --replicas=4 rc/a-example-1

Run a test of the scaled application

	for i in {1..10}; do curl ab-service-ab-example.cloudapps.example.com; echo " "; done
	
	Application VERSION 1 -- Pod IP: 10.1.0.12
	Application VERSION 1 -- Pod IP: 10.1.0.13
	Application VERSION 1 -- Pod IP: 10.1.1.18
	Application VERSION 1 -- Pod IP: 10.1.1.19
	Application VERSION 1 -- Pod IP: 10.1.0.12
	Application VERSION 1 -- Pod IP: 10.1.0.13
	Application VERSION 1 -- Pod IP: 10.1.1.18
	Application VERSION 1 -- Pod IP: 10.1.1.19
	Application VERSION 1 -- Pod IP: 10.1.0.12
	Application VERSION 1 -- Pod IP: 10.1.0.13

Edit php index.php on github, i.e. increment app version

Browser - Add to Project

	php:5.5
	Name: b-example
	https://github.com/kenthua/ab-example.git
	Routing: Create a route to the application: No
	Labels: abgroup=true

Run a test of the same route with the newly added project, with the label abgroup=true 
Notice that VERSION 2 is now in the load balancing scheme

	for i in {1..10}; do curl ab-service-ab-example.cloudapps.example.com; echo " "; done
	
	Application VERSION 1 -- Pod IP: 10.1.0.12
	Application VERSION 1 -- Pod IP: 10.1.0.13
	Application VERSION 2 -- Pod IP: 10.1.0.14
	Application VERSION 1 -- Pod IP: 10.1.1.18
	Application VERSION 1 -- Pod IP: 10.1.1.19
	Application VERSION 1 -- Pod IP: 10.1.0.12
	Application VERSION 1 -- Pod IP: 10.1.0.13
	Application VERSION 2 -- Pod IP: 10.1.0.14
	Application VERSION 1 -- Pod IP: 10.1.1.18
	Application VERSION 1 -- Pod IP: 10.1.1.19
	
Scale down VERSION 1 and Scale up VERSION 2

	oc scale --replicas=2 rc/a-example-1
	oc scale --replicas=2 rc/b-example-1
	
Run another test

	for i in {1..10}; do curl ab-service-ab-example.cloudapps.example.com; echo " "; done
	
	Application VERSION 1 -- Pod IP: 10.1.0.12
	Application VERSION 1 -- Pod IP: 10.1.0.13
	Application VERSION 2 -- Pod IP: 10.1.0.14
	Application VERSION 2 -- Pod IP: 10.1.1.21
	Application VERSION 1 -- Pod IP: 10.1.0.12
	Application VERSION 1 -- Pod IP: 10.1.0.13
	Application VERSION 2 -- Pod IP: 10.1.0.14
	Application VERSION 2 -- Pod IP: 10.1.1.21
	Application VERSION 1 -- Pod IP: 10.1.0.12
	Application VERSION 1 -- Pod IP: 10.1.0.13
	
Scale up VERSION 2 and Scale down VERSION 1

	oc scale --replicas=4 rc/b-example-1
	oc scale --replicas=0 rc/a-example-1	
	
Last test

	for i in {1..10}; do curl ab-service-ab-example.cloudapps.example.com; echo " "; done

	Application VERSION 2 -- Pod IP: 10.1.0.14
	Application VERSION 2 -- Pod IP: 10.1.0.17
	Application VERSION 2 -- Pod IP: 10.1.1.21
	Application VERSION 2 -- Pod IP: 10.1.1.24
	Application VERSION 2 -- Pod IP: 10.1.0.14
	Application VERSION 2 -- Pod IP: 10.1.0.17
	Application VERSION 2 -- Pod IP: 10.1.1.21
	Application VERSION 2 -- Pod IP: 10.1.1.24
	Application VERSION 2 -- Pod IP: 10.1.0.14
	Application VERSION 2 -- Pod IP: 10.1.0.17

# MLB Parks app and db, create app and add db, 3.1
Last Tested: 3.1
Added: 2016-01-21

From Grant Shipley, thanks Grant!

Browser - New Project
	
	mlbparks

Browser - Add to Project

	jboss-eap64-openshift:1.1
	Name: mlbparks
	https://github.com/kenthua/openshift3mlbparks.git

When the application is built and ready  
Browser - Navigate to  

	http://mlbparks-mlbparks.cloudapps.example.com
	
Note the empty map, we need to add a database  
Browser - Add to Project

	mongodb-ephemeral
	MONGODB_USER : mlbparks
	MONGODB_PASSWORD : mlbparks
	MONGODB_DATABASE: mlbparks
	MONGODB_ADMIN_PASSWORD : mlbparks

Console - As User  
	
	oc project mlbparks
	oc env dc mlbparks -e MONGODB_USER=mlbparks -e MONGODB_PASSWORD=mlbparks -e MONGODB_DATABASE=mlbparks

This will trigger a new dc build of the application pod with the new environment variables  
Once the re-build is complete and ready  

You can check for the new activity in the browser or the console with `oc get pods`

Browser - navigate to

	http://mlbparks-mlbparks.cloudapps.example.com

# MLB Parks app and db, template, 3.1
Last Tested: 3.1
Added: 2016-01-21

From Grant Shipley, thanks Grant!

Console - As User 

	oc new-project mlbparkstemplate
	oc create -f https://raw.githubusercontent.com/kenthua/openshift3mlbparks/master/mlbparks-template.json
	oc new-app mlbparks
	
Everything is predefined / generated

	--> Deploying template mlbparks for "mlbparks"
	     With parameters:
	      APPLICATION_NAME=mlbparks
	      APPLICATION_DOMAIN=
	      SOURCE_REPOSITORY_URL=https://github.com/kenthua/openshift3mlbparks
	      SOURCE_REPOSITORY_REF=master
	      CONTEXT_DIR=
	      HORNETQ_QUEUES=
	      HORNETQ_TOPICS=
	      HORNETQ_CLUSTER_PASSWORD=juSOlaGS # generated
	      GITHUB_WEBHOOK_SECRET=ywa7SxpE # generated
	      GENERIC_WEBHOOK_SECRET=OFjGeUmX # generated
	      IMAGE_STREAM_NAMESPACE=openshift
	      DATABASE_SERVICE_NAME=mongodb
	      MONGODB_USER=userFJX # generated
	      MONGODB_PASSWORD=ORhBvEYc0CufVJ87 # generated
	      MONGODB_DATABASE=sampledb
	      MONGODB_ADMIN_PASSWORD=YDdxL8wmSvlk6veE # generated
	--> Creating resources with label app=mlbparks ...
	    Service "mlbparks" created
	    Route "mlbparks" created
	    ImageStream "mlbparks" created
	    BuildConfig "mlbparks" created
	    DeploymentConfig "mlbparks" created
	    Service "mongodb" created
	    DeploymentConfig "mongodb" created
	--> Success
	    Build scheduled for "mlbparks" - use the logs command to track its progress.
	    Run 'oc status' to view your app.

Once the application is built and the application pod is running  

	oc get pods
	
	NAME               READY     STATUS      RESTARTS   AGE
	mlbparks-1-build   0/1       Completed   0          4m
	mlbparks-1-pcv1o   1/1       Running     0          27s
	mongodb-1-3sp8n    1/1       Running     0          4m

Browser - navigate to  

	http://mlbparks-mlbparkstemplate.cloudapps.example.com

	
# PHP, persistent volumes, 3.1
Last Tested: 3.1.1.6  
(b4m) / 20m  

If you don't have a persistent volume already created by root, reference this repo for a quick NFS & PV setup:  
https://github.com/kenthua/openshift-configs/tree/master/root

Browser - New Project (Home view)

	php

Browser - Add to Project

	php:5.6
	https://github.com/kenthua/openshift-php-upload-demo.git
	Name: openshift-php-upload
	
Create a claim on a volume

	oc create -f pvc.json

	oc get pvc
	NAME       LABELS    STATUS    VOLUME    CAPACITY   ACCESSMODES   AGE
	phpclaim   <none>    Bound     vol1      5Gi        RWX           5s

Need to edit the deployment config to leverage the volume

	oc edit dc openshift-php-upload

First, directly under the `template \n spec:` line, add this YAML (indented from the `spec:` line):

	  volumes:
      - name: php-upload-volume
        persistentVolumeClaim:
          claimName: phpclaim

Then to have the container mount this, add this YAML after the `terminationMessagePath:` line:

        volumeMounts:
        - mountPath: /opt/app-root/src/uploaded
          name: php-upload-volume

Automatically triggers a new deploy

Browser - navigate to

	http://openshift-php-upload-php.cloudapps.example.com/form.html

Scale the php upload app

	oc get rc
	CONTROLLER               CONTAINER(S)           IMAGE(S)                                                                                                             SELECTOR                                                                  REPLICAS   AGE
	openshift-php-upload-1   openshift-php-upload   172.30.90.52:5000/php/openshift-php-upload@sha256:55e28b206ca7ead87e3053b538886293c56ad40863d08c55ddd406f044349245   deployment=openshift-php-upload-1,deploymentconfig=openshift-php-upload   0          3m
	openshift-php-upload-2   openshift-php-upload   172.30.90.52:5000/php/openshift-php-upload@sha256:55e28b206ca7ead87e3053b538886293c56ad40863d08c55ddd406f044349245   deployment=openshift-php-upload-2,deploymentconfig=openshift-php-upload   1          1m
	
	oc scale --replicas=3 rc/openshift-php-upload-2
	
	oc get pod
	NAME                           READY     REASON       RESTARTS   AGE
	openshift-php-upload-1-build   0/1       ExitCode:0   0          24m
	openshift-php-upload-2-31eng   1/1       Running      0          6m
	openshift-php-upload-2-53f4z   1/1       Running      0          24s
	openshift-php-upload-2-oc0g5   1/1       Running      0          24s

Check for persistent volume saving, also round robin service
ose-aio machine 
	
	ls /var/export/vol1
	
# Ruby hello-world with db different project, Ruby Instant App, 3.0
Last Tested: 3.0.0  

Browser - New Project (Home View)

	data	

Browser - Add to Project - browse all templates 

	mysql-ephemeral

Edit Deployment Configuration - Create

	DATABASE_SERVICE_NAME=mysql
	MYSQL_USER=root
	MYSQL_PASSWORD=redhat
	MYSQL_DATABASE=mydb

Verify mysql-1 pod is running

	oc project data
	
	oc get pod
	NAME            READY     REASON    RESTARTS   AGE
	mysql-1-dppdz   1/1       Running   0          1m
	
	oc get service
	NAME      LABELS                              SELECTOR     IP(S)           PORT(S)
	mysql     template=mysql-ephemeral-template   name=mysql   172.30.237.51   3306/TCP
	
	curl 172.30.237.51:3306
	5.5.41exO_r>}{��qHP9j.DK,9yxmysql_native_password!��#08S01Got packets out of order	

Add Instant App (as system:admin - root user)

	oc create -f ruby-hello-world-template.json -n openshift

Browser - New Project (Home View)

	frontend	

Browser - Add to Project - Create Using a Template 

	ruby-hello-world-template

Click Create - (note parameters already entered) 

Check that the frontend pod is running

	oc project frontend
	
	oc get pod 
	NAME                       READY     REASON       RESTARTS   AGE
	ruby-hello-world-1-build   0/1       ExitCode:0   0          2m
	ruby-hello-world-1-trpn3   1/1       Running      0          1m

Browser - Navigate to:

	http://ruby-hello-world.frontend.cloudapps.example.com


# Ruby hello-world with db different project, 3.0
Last Tested: 3.0.0  

Browser - New Project (Home View)

	data	

Browser - Add to Project - browse all templates 

	mysql-ephemeral

Edit Deployment Configuration - Create

	DATABASE_SERVICE_NAME=mysql
	MYSQL_USER=root
	MYSQL_PASSWORD=redhat
	MYSQL_DATABASE=mydb

Verify mysql-1 pod is running

	oc project data
	
	oc get pod
	NAME            READY     REASON    RESTARTS   AGE
	mysql-1-dppdz   1/1       Running   0          1m
	
	oc get service
	NAME      LABELS                              SELECTOR     IP(S)           PORT(S)
	mysql     template=mysql-ephemeral-template   name=mysql   172.30.237.51   3306/TCP
	
	curl 172.30.237.51:3306
	5.5.41exO_r>}{��qHP9j.DK,9yxmysql_native_password!��#08S01Got packets out of order	

Browser - New Project (Home View)

	frontend	

Browser - Add to Project

	http://github.com/kenthua/ruby-hello-world.git
	ruby:2.0

Edit Deployment Configuration by adding some environment variables

	DATABASE_SERVICE_HOST=mysql.data.svc.cluster.local
	DATABASE_SERVICE_PORT=3306
	MYSQL_USER=root
	MYSQL_PASSWORD=redhat
	MYSQL_DATABASE=mydb

Check that the frontend pod is running

	oc project frontend
	
	oc get pod 
	NAME                       READY     REASON       RESTARTS   AGE
	ruby-hello-world-1-build   0/1       ExitCode:0   0          2m
	ruby-hello-world-1-trpn3   1/1       Running      0          1m

Browser - Navigate to:

	http://ruby-hello-world.frontend.cloudapps.example.com

# PHP Upload Application Template, Instant App, 3.0
Last Tested: 3.0.0  

As admin/root user

	oc create -f php-upload.json -n openshift

Browser - New Project (Home View)

	template-test

Browser - Add to Project -> Select Template -> Create

	template: php-upload-template

Browser - Browse -> Builds -> Start build

Browser - navigate to:

	http://php-upload.template-test.cloudapps.example.com/form.html	

# PHP Upload Application, Instant App, 3.0
Last Tested: 3.0.0  

	oc new-project newapp-test
	oc new-app php-upload.json
	oc start-build php-upload

Browser - navigate to:

	http://php-upload.newapp-test.cloudapps.example.com/form.html


	# Ruby hello-world, 3.0
	Last Tested: 3.0.0  
	(b6m) / 25m  

	Browser - New Project

		ruby	

	Browser - Add to Project

		https://github.com/kenthua/ruby-hello-world.git
		ruby:2.0

	Edit Deployment Configuration

		MYSQL_USER=root
		MYSQL_PASSWORD=redhat
		MYSQL_DATABASE=mydb

	Browser - Browse -> Services -> Navigate to URL

		http://ruby-hello-world.ruby.cloudapps.example.com

	Browser - Add to Project -> browse all templates

		mysql-empemeral

	Edit parameters

		DATABASE_SERVICE_NAME=database
		POSTGRESQL_USER=root
		POSTGRESQL_PASSWORD=redhat
		POSTGRESQL_DATABASE=mydb

	Verify database-1 and ruby-hello-world-1 pods are running

		oc get pod
		NAME                       READY     REASON       RESTARTS   AGE
		database-1-aytfl           1/1       Running      0          20s
		ruby-hello-world-1-build   0/1       ExitCode:0   0          10m
		ruby-hello-world-1-jc1jg   1/1       Running      0          4m

	Browser - app still broken  
	Need to force a rebuild with of the POD, because the original frontend environment didn't have DATABASE_SERVICE_HOST environemnt variable

		oc delete pod `oc get pod | grep -e "hello-world-[0-9]" | grep -v build | awk '{print $1}'`

	Old pod is deleted and a new pod is spawned to meet the desired state of replica size = 1
	Refresh app again

	Make a change to the application

	Now we need to get the generic webhook url

		oc describe bc ruby-hello-world
		
		Name:			ruby-hello-world
		...
		Webhook Generic:	https://ose-aio.example.com:8443/oapi/v1/namespaces/ruby/buildconfigs/ruby-hello-world/webhooks/1f4a60ac41f59d9b/generic
		...
		Builds:
		  Name			Status		Duration	Creation Time
		  ruby-hello-world-1 	complete 	6m6s 		2015-07-17 19:20:23 -0400 EDT
		 
	Trigger a new build manually via webhook

		curl -i -H "Accept: application/json" \
		-H "X-HTTP-Method-Override: PUT" -X POST -k \
		https://ose-aio.example.com:8443/oapi/v1/namespaces/ruby/buildconfigs/ruby-hello-world/webhooks/1f4a60ac41f59d9b/generic
		
		HTTP/1.1 200 OK
		Cache-Control: no-store
		Date: Fri, 17 Jul 2015 23:40:50 GMT
		Content-Length: 0
		Content-Type: text/plain; charset=utf-8

	Check out a new build

		oc get build
		NAME                 TYPE      STATUS     POD
		ruby-hello-world-1   Source    Complete   ruby-hello-world-1-build
		ruby-hello-world-2   Source    Running    ruby-hello-world-2-build

	Once ready, check out the new changes

	Rollback to the original
		
		oc rollback ruby-hello-world-1
		
	Rollback to the changes if desired

		oc rollback ruby-hello-world-2
		
	Check out how many rc's we have

		oc get rc
		CONTROLLER           CONTAINER(S)       IMAGE(S)                                                                                                          SELECTOR                                                          REPLICAS
		database-1           mysql              registry.access.redhat.com/openshift3/mysql-55-rhel7:latest                                                       deployment=database-1,deploymentconfig=database,name=database     1
		ruby-hello-world-1   ruby-hello-world   172.30.56.67:5000/ruby/ruby-hello-world@sha256:84b3c3a091f9bc7fb5530c126add792df93a29b779fb7abcc26291ba79a339d9   deployment=ruby-hello-world-1,deploymentconfig=ruby-hello-world   0
		ruby-hello-world-2   ruby-hello-world   172.30.56.67:5000/ruby/ruby-hello-world@sha256:a6a81a82cd4305e9b50cb189875d4cc7f1dd5a9c42c6b956db36726a14bd8e5a   deployment=ruby-hello-world-2,deploymentconfig=ruby-hello-world   0
		ruby-hello-world-3   ruby-hello-world   172.30.56.67:5000/ruby/ruby-hello-world@sha256:84b3c3a091f9bc7fb5530c126add792df93a29b779fb7abcc26291ba79a339d9   deployment=ruby-hello-world-3,deploymentconfig=ruby-hello-world   0
		ruby-hello-world-4   ruby-hello-world   172.30.56.67:5000/ruby/ruby-hello-world@sha256:a6a81a82cd4305e9b50cb189875d4cc7f1dd5a9c42c6b956db36726a14bd8e5a   deployment=ruby-hello-world-4,deploymentconfig=ruby-hello-world   1



---


# References
https://github.com/openshift/training  
https://github.com/jim-minter/ose3-ticket-monster  
https://github.com/gshipley/openshift3mlbparks  


