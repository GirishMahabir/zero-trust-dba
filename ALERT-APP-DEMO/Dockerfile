FROM python:3.11-bookworm

ADD main.py .

RUN pip install elasticsearch

# Set default directory
WORKDIR /

# Run the application
CMD [ "python3", "main.py" ]