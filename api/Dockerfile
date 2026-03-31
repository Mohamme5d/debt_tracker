FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["Ijari.Api/Ijari.Api.csproj", "Ijari.Api/"]
COPY ["Ijari.Core/Ijari.Core.csproj", "Ijari.Core/"]
COPY ["Ijari.Infrastructure/Ijari.Infrastructure.csproj", "Ijari.Infrastructure/"]
RUN dotnet restore "Ijari.Api/Ijari.Api.csproj"
COPY . .
WORKDIR "/src/Ijari.Api"
RUN dotnet build "Ijari.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Ijari.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS=http://+:5000
ENTRYPOINT ["dotnet", "Ijari.Api.dll"]
