# Java Application

This directory contains the source code for the Java application (Spring Petclinic).

## Source Code
The source code is located in the [spring-petclinic](./spring-petclinic) directory.

## License
The application is licensed under the **Apache License 2.0**.

This license allows:
1.  **Use**: You can use the code for commercial or personal purposes.
2.  **Modification**: You can modify the code as needed.
3.  **Redistribution**: You can redistribute the code in your own repository.

**Note**: You must retain the original [LICENSE.txt](./spring-petclinic/LICENSE.txt) file and any copyright notices.

## Docker
A `Dockerfile` is provided in this directory to build the application.

### Build and Push
To build and push the image to Docker Hub, use the following commands:

```bash
# Build the image
docker build -t java-app:latest .

# Tag the image (Correct Name: petclinic-depi)
docker tag java-app:latest mohamedelsayed22/petclinic-depi:v1

# Push to Docker Hub
docker push mohamedelsayed22/petclinic-depi:v1
```
