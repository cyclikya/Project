# 1. Áèëä ïðîåêòà
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Êîïèðóåì è âîññòàíàâëèâàåì çàâèñèìîñòè
COPY ["Project.csproj", "./"]
RUN dotnet restore "Project.csproj"

# Êîïèðóåì èñõîäíûé êîä
COPY . .
WORKDIR "/src"

# Ñîáèðàåì ïðîåêò
RUN dotnet build "Project.csproj" -c Release --no-restore

# Ïóáëèêóåì ïðîåêò
RUN dotnet publish "Project.csproj" -c Release -o /app/publish \
    --no-restore \
    --no-build \
    --self-contained false

# 2. Ôèíàëüíûé îáðàç
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Óñòàíàâëèâàåì ñèñòåìíûå çàâèñèìîñòè äëÿ PostgreSQL (åñëè íóæíî)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Êîïèðóåì ñîáðàííîå ïðèëîæåíèå
COPY --from=build /app/publish .

# Ïåðåìåííûå îêðóæåíèÿ
ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_SYSTEM_NET_MAIL_SMTPSERVER=smtp.gmail.com
ENV DOTNET_SYSTEM_NET_MAIL_SMTPPORT=587
ENV ASPNETCORE_URLS=http://+:8080

# Áåçîïàñíîñòü - çàïóñê îò non-root ïîëüçîâàòåëÿ
RUN groupadd -r dotnetuser && useradd -r -g dotnetuser dotnetuser
RUN chown -R dotnetuser:dotnetuser /app
USER dotnetuser

EXPOSE 8080

ENTRYPOINT ["dotnet", "Project.dll"]
