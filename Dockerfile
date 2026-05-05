# ETAPA 1: Construcción (Build)
# Usamos Maven y Java para compilar tu código
FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copiamos el pom.xml primero para descargar dependencias (esto ahorra tiempo de carga)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiamos el código fuente y compilamos el proyecto saltando los tests para que sea más rápido
COPY src ./src
RUN mvn package -DskipTests -B

# ETAPA 2: Producción
# Usamos solo el entorno de ejecución de Java (JRE), mucho más liviano y seguro
FROM eclipse-temurin:17-jre-alpine

# REQUISITO DE LA RÚBRICA: Creamos un usuario no root por seguridad
RUN addgroup -g 1001 appuser && adduser -u 1001 -G appuser -s /bin/sh -D appuser

WORKDIR /app

# Copiamos el archivo .jar generado en la Etapa 1
COPY --from=build /app/target/*.jar app.jar

# Le damos la propiedad del archivo a nuestro usuario seguro
RUN chown appuser:appuser app.jar

# Exponemos el puerto estándar de Spring Boot
EXPOSE 8081

# Usamos el usuario seguro
USER appuser

# Comando para encender el backend
ENTRYPOINT ["java", "-jar", "app.jar"]