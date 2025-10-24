# 1. Билд проекта
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Копируем и восстанавливаем зависимости
COPY ["task5.csproj", "./"]
RUN dotnet restore "task5.csproj"

# Копируем исходный код
COPY . .
WORKDIR "/src"

# Собираем проект
RUN dotnet build "task5.csproj" -c Release --no-restore

# Публикуем проект
RUN dotnet publish "task5.csproj" -c Release -o /app/publish \
    --no-restore \
    --no-build \
    --self-contained false

# 2. Финальный образ
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Устанавливаем системные зависимости для PostgreSQL (если нужно)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Копируем собранное приложение
COPY --from=build /app/publish .

# Переменные окружения
ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_SYSTEM_NET_MAIL_SMTPSERVER=smtp.gmail.com
ENV DOTNET_SYSTEM_NET_MAIL_SMTPPORT=587
ENV ASPNETCORE_URLS=http://+:8080

# Безопасность - запуск от non-root пользователя
RUN groupadd -r dotnetuser && useradd -r -g dotnetuser dotnetuser
RUN chown -R dotnetuser:dotnetuser /app
USER dotnetuser

EXPOSE 8080

ENTRYPOINT ["dotnet", "task5.dll"]