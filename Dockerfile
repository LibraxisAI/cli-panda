# Wybierz obraz bazowy - np. oficjalny obraz Python
FROM python:3.11-slim

# Ustaw katalog roboczy w kontenerze
WORKDIR /app

# Skopiuj pliki zależności
COPY requirements.txt pyproject.toml ./

# Zainstaluj zależności
# Jeśli używasz poetry (z pyproject.toml) lub innego managera, dostosuj tę komendę
RUN pip install --no-cache-dir -r requirements.txt
# Możesz też potrzebować `uv pip install -r requirements.txt` jeśli używasz `uv`

# Skopiuj resztę aplikacji do kontenera
COPY . .

# Tutaj zdefiniuj, co agent ma robić po uruchomieniu.
# To zależy od tego, jak "CURSOR Background Agent" ma interfejsować się z Twoim kodem.
# Dokumentacja Cursor powinna dostarczyć informacji, czy wymagany jest specyficzny CMD lub ENTRYPOINT.
# Dla przykładu, jeśli agent ma po prostu mieć dostępne środowisko:
CMD ["bash"] 