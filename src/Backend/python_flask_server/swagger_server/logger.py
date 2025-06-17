import logging
from logging.handlers import TimedRotatingFileHandler

# Tägliche Rotation, behalte maximal 7 Logdateien
file_handler = TimedRotatingFileHandler(
    "app.log", when="midnight", interval=1, backupCount=7, encoding="utf-8"
)
file_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))

stream_handler = logging.StreamHandler()
stream_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))

logging.basicConfig(
    level=logging.INFO,
    handlers=[file_handler, stream_handler]
)

logger = logging.getLogger("HikeMate")