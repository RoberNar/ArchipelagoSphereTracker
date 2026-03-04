# Stage 1: Build from source
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet publish ArchipelagoSphereTracker.csproj \
    -c Release \
    -r linux-x64 \
    /p:SelfContained=true \
    /p:PublishSingleFile=true \
    /p:PublishTrimmed=false \
    /p:IncludeAllContentForSelfExtract=true \
    -o /app

# Stage 2: Minimal runtime image
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0
WORKDIR /app
COPY --from=build /app .
RUN chmod +x ArchipelagoSphereTracker

# Crear un script de arranque ultra-verboso (con logs)
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'echo "--- DIAGNOSTIC START ---"' >> /app/start.sh && \
    echo 'echo "Variable cruda de Railway: $DISCORD_TOKEN"' >> /app/start.sh && \
    echo 'echo "DISCORD_TOKEN=$DISCORD_TOKEN" > .env' >> /app/start.sh && \
    echo 'echo "--- .ENV CREATED. CONTENTS: ---"' >> /app/start.sh && \
    echo 'cat .env' >> /app/start.sh && \
    echo 'echo "--- STARTING BOT ---"' >> /app/start.sh && \
    echo 'exec ./ArchipelagoSphereTracker --NormalMode' >> /app/start.sh && \
    chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]
