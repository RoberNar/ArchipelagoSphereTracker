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

# Generate strictly formatted .env file, removing any whitespace/newlines
ENTRYPOINT ["/bin/sh", "-c", "printf 'DISCORD_TOKEN=%s' \"$(echo $DISCORD_TOKEN | tr -d ' ' | tr -d '\n' | tr -d '\r')\" > .env && ./ArchipelagoSphereTracker --NormalMode"]
