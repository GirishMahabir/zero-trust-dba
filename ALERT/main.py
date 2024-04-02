#!/usr/bin/env python3

from elasticsearch import Elasticsearch
from ssl import create_default_context
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
import time
import os


def get_documents(es, index_name, size=25, sort='desc'):
    res = es.search(index=index_name, body={
                    "query": {"match_all": {}}, "size": size,
                    "sort": {"@timestamp": {"order": f"{sort}"}}})
    return res


def filter_fields(res, fields=[]):
    # Return the fields requested from the response.
    hits = res['hits']['hits']
    filtered_hits = []
    for hit in hits:
        filtered_hit = {}
        for field in fields:
            filtered_hit[field] = hit['_source'][field]
        filtered_hits.append(filtered_hit)
    return filtered_hits


def search_in_field(filtered_hits, field, search_term, log_type='mysql-audit'):

    search_results = []

    # Search for a term in a field.
    if log_type == 'mysql-audit':  # MariaDB Audit Log.
        if field == 'message':  # Search in the message field.
            # 20240402 07:34:31,3fecf9b15cf7,root,localhost,2341,4533,QUERY,employees,'SET SESSION character_set_results = \'utf8mb4\'',0
            # date time, thread_id, user, host, connection_id, query_id, command_type, database, query, query_time
            for hit in filtered_hits:
                # Break the message into parts.
                parts = hit[field].split(',')
                query = parts[8].split(' ')
                for word in query:
                    if word == search_term:
                        search_results.append(hit)
                        break

    return search_results


def construct_html_email(search_results, detection_type):
    # Construct an email with the search results.
    # 20240402 07:34:31,3fecf9b15cf7,root,localhost,2341,4533,QUERY,employees,'SET SESSION character_set_results = \'utf8mb4\'',0
    # date time, thread_id, user, host, connection_id, query_id, command_type, database, query, query_time

    # Split the search results into individual fields.
    search_results = search_results.split(',')
    date_time = search_results[0]
    time = date_time.split(' ')[1]
    thread_id = search_results[1]
    user = search_results[2]
    host = search_results[3]
    connection_id = search_results[4]
    query_id = search_results[5]
    command_type = search_results[6]
    database = search_results[7]
    query = search_results[8] + search_results[9]
    query_time = search_results[10]

    # Construct an HTML email.
    html_email = f"""
    <html>
    <body>
        <h2>DETECTED: {detection_type} </h2>
        <p>Time: {time}</p>
        <p>Thread ID: {thread_id}</p>
        <p>User: {user}</p>
        <p>Host: {host}</p>
        <p>Connection ID: {connection_id}</p>
        <p>Query ID: {query_id}</p>
        <p>Command Type: {command_type}</p>
        <p>Database: {database}</p>
        <p>Query: {query}</p>
        <p>Query Time: {query_time}</p>
    </body>
    </html>
    """

    return html_email


def send_email(html_email, subject, sender, smtp_server, smtp_port, smtp_username, smtp_password, recipient):
    print("SENDING EMAIL")

    # Create a MIMEText object.
    msg = MIMEMultipart()
    msg['From'] = sender
    msg['To'] = recipient
    msg['Subject'] = subject

    # Attach the HTML email to the MIMEText object.
    msg.attach(MIMEText(html_email, 'html'))

    # Send the email.
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        # server.starttls()
        server.login(smtp_username, smtp_password)
        server.sendmail(sender, recipient, msg.as_string())

    print('Email sent successfully.')


def get_unique_query_id(search_result):
    search_result = search_result.split(',')
    print('search_result:', search_result)
    print('query_id:', search_result[5])
    return search_result[5]


def main():
    script_path = os.path.dirname(os.path.abspath(__file__))
    context = create_default_context(
        cafile=os.path.join(script_path, "ca.crt"))
    es = Elasticsearch(
        ['https://localhost:9200'],
        basic_auth=('elastic', 'vu4foh3fo8Iquai1saepee5shi5aroh7'),
        ssl_context=context,
    )

    unique_queries = []

    while True:
        index_name = 'mysql-logs-audit*'
        res = get_documents(es, index_name, size=10000, sort='desc')
        fields = ['message']
        filtered_hits = filter_fields(res, fields)
        search = search_in_field(filtered_hits, 'message',
                                 'SQL_NO_CACHE', 'mysql-audit')
        search = search[0]

        query_id = get_unique_query_id(search['message'])

        if query_id not in unique_queries:
            print('unique_queries:', unique_queries)
            unique_queries.append(query_id)

            # Construct an HTML email.
            html_email = construct_html_email(
                search['message'], 'DUMP DETECTED')

            # Send the email.
            send_email(html_email, 'ALERT: DUMP DETECTED', 'ALERT: DUMP DETCECTED',
                       '127.0.0.1', 1025, '', '', 'admin@localhost')

        time.sleep(60)


if __name__ == '__main__':
    main()
