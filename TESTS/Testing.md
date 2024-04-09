- **TC1: Zero-Trust Verification**
    - *Objective*: Test adherence to zero-trust principles for all access attempts.
    - *Steps*: Try accessing database resources from various network points with different user roles.
    - *Expected Outcome*: Only verified users can access, with unverified attempts logged and blocked.
    - *Actual Outcome*: 
    In our test deployment, since we used container rather than full VMs. We could not apply the production level security measures that we explained in details in the `Production Implementation Section`. However, to highlight the points here, we have two security measure that we have to implement in the production environment: 1. The firewall rules to block all incoming traffic except the ones that are necessary for the services to communicate. 2. The proper MYSQL HOST Field configuration to allow only connections from the proxysql IP address.

    Morover, We did the below change in our deployment to add atleast one level of security.
    1. Deploy the Stack as planned.
    2. Inspect the docker container of proxysql to get its IP address.
    3. Apply the change on mysql: `RENAME USER 'data_ops'@'%' TO 'data_ops'@'192.168.48.7';` assuming that the IP address of the proxysql is `192.168.48.7`.

    Tests:
    - Accessing the database from the host machine: `mysql -h127.0.0.1 -P3306 -udata_ops -p`
    ```
    ERROR 1045 (28000): Access denied for user 'data_ops'@'192.168.48.1' (using password: YES)
    ```
    - Accessing the database from another machine: `mysql -h127.0.0.1 -P6033 -udata_ops -p`
    ```
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MySQL connection id is 4
    Server version: 5.5.30 (ProxySQL)

    Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    MySQL [(none)]> 
    ```

    Hence, we could see that with the above change, we could block the access from the host machine and allow only the access from the proxysql machine. This is a very basic level of security that we could implement in our test deployment. But we have to implement the firewall rules and the proper MYSQL HOST Field configuration to allow only connections from the proxysql IP address in the production environment. Furthermore, we need to also change on which host mysql service listens on, that is change it from `0.0.0.0` to a specific IP address.

- **TC2: Data Encryption Integrity**
    - *Objective*: Ensure data is encrypted at-rest and in-transit.
    - *Steps*: Check disk encryption for at-rest data and capture network packets for in-transit data.
    - *Expected Outcome*: Data is unreadable without proper decryption, ensuring full encryption.
    - *Actual Outcome*: 
        - DATA AT-REST:
        ```sql
        -- Before Encryption
        -- root ➜ .../DATA/mariadb-master/data/employees $ strings titles.ibd | head -n10
        infimum
        supremum
        Senior Engineer
        7<Senior Engineer
        Senior Engineer
        infimum
        supremum
        Senior Engineer
        Staff
        Senior Engineer
        -- After Encryption
        -- root ➜ .../DATA/mariadb-master/data/employees $ strings titles.ibd | head -n10
        O"w_
        D!srA
        3)f2
        Z5LX&
        p;oR
        Tk' 
        ZG2P;
        \Ums
        C,prL
        aRyGX
        ```
        - DATA IN-TRANSIT: Show some screenshots of the network packets captured during the test.


- **TC3: Performance Under Security Constraints**
    - *Objective*: Evaluate performance impact due to security protocols.
    - *Steps*: Measure system performance with security features enabled compared to a baseline.
    - *Expected Outcome*: Minimal performance degradation, maintaining high efficiency.
    - *Actual Outcome*: 
    ```
    CREATE SCHEMA sbtest;
    CREATE USER 'sbtest'@'%' IDENTIFIED BY 'pass' REQUIRE SSL;
    GRANT ALL PRIVILEGES ON sbtest.* TO 'sbtest'@'%';
    FLUSH PRIVILEGES;

    COPY cacert.pem, client-cert.pem, client-key.pem to current directory.

    sysbench /usr/share/sysbench/oltp_read_write.lua --threads=4 --mysql-host=127.0.0.1 --mysql-user=sbtest --mysql-password=pass --mysql-port=3306 --mysql-ssl=on --tables=10 --table-size=10000 prepare

    sysbench /usr/share/sysbench/oltp_read_write.lua --threads=8 --events=0 --time=300 --mysql-host=127.0.0.1 --mysql-user=sbtest --mysql-password=pass --mysql-ssl=on --mysql-port=3306 --tables=10 --delete_inserts=10 --index_updates=10 --non_index_updates=10 --table-size=10000 --db-ps-mode=disable --report-interval=1 run

    SQL statistics:
        queries performed:
            read:                            234780
            write:                           616502
            other:                           31459
            total:                           882741
        transactions:                        14689  (48.93 per sec.)
        queries:                             882741 (2940.64 per sec.)
        ignored errors:                      2081   (6.93 per sec.)
        reconnects:                          0      (0.00 per sec.)

    General statistics:
        total time:                          300.1864s
        total number of events:              14689

    Latency (ms):
            min:                                   19.50
            avg:                                  163.44
            max:                                 2630.26
            95th percentile:                      369.77
            sum:                              2400705.67

    Threads fairness:
        events (avg/stddev):           1836.1250/25.60
        execution time (avg/stddev):   300.0882/0.06




        sysbench /usr/share/sysbench/oltp_read_write.lua --threads=4 --mysql-host=127.0.0.1 --mysql-user=sbtest --mysql-password=pass --mysql-port=3306 --tables=10 --table-size=10000 prepare

        sysbench /usr/share/sysbench/oltp_read_write.lua --threads=8 --events=0 --time=300 --mysql-host=127.0.0.1 --mysql-user=sbtest --mysql-password=pass  --mysql-port=3306 --tables=10 --delete_inserts=10 --index_updates=10 --non_index_updates=10 --table-size=10000 --db-ps-mode=disable --report-interval=1 run

    SQL statistics:
        queries performed:
            read:                            247772
            write:                           650203
            other:                           33192
            total:                           931167
        transactions:                        15494  (51.63 per sec.)
        queries:                             931167 (3102.70 per sec.)
        ignored errors:                      2204   (7.34 per sec.)
        reconnects:                          0      (0.00 per sec.)

    General statistics:
        total time:                          300.1145s
        total number of events:              15494

    Latency (ms):
            min:                                   17.13
            avg:                                  154.92
            max:                                 6005.59
            95th percentile:                      344.08
            sum:                              2400333.69

    Threads fairness:
        events (avg/stddev):           1936.7500/20.31
        execution time (avg/stddev):   300.0417/0.03

    ```

    Conclusion: 
    ```
    	                        UNENCRYPTED	    ENCRYPTED	    IMPACT
    Transactions per second:	    51.63	    42.82	    17.0637226418749
    Queries per second	            3102.7	    2565.95	    17.2994488671157
    Average latency (ms)	        154.92	    186.77	    20.5589981926156
    95th percentile latency(ms)	    344.08	    404.61	    17.5918391071844

    ```

- **TC4: Failover and Recovery Time**
    - *Objective*: Assess the failover mechanism and recovery time in case of a database outage.
    - *Steps*: Simulate a failure of the primary database server and measure the time taken for ProxySQL to redirect queries to the secondary server.
    - *Expected Outcome*: Failover to the secondary server occurs within a pre-defined time frame, ensuring high availability.
    - *Actual Outcome*: 
            ENC
                Relay_Log_File: mysql-relay-bin.000003
                 Relay_Log_Pos: 849928302
         Relay_Master_Log_File: mysql-bin.000002
               Relay_Log_Space: 956705603
         Seconds_Behind_Master: 130 MAX 145
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL

            UNENC
                Relay_Log_File: mysql-relay-bin.000004
                 Relay_Log_Pos: 447720735
         Relay_Master_Log_File: mysql-bin.000003
               Relay_Log_Space: 576190969
         Seconds_Behind_Master: 137
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL

                           Relay_Log_File: mysql-relay-bin.000004
                 Relay_Log_Pos: 476295288
         Relay_Master_Log_File: mysql-bin.000003
               Relay_Log_Space: 576190969
         Seconds_Behind_Master: 145
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL




- **TC5: SQL Injection Defense**
    - *Objective*: Assess system's resilience against SQL injection.
    - *Steps*: Perform SQL injection attacks in controlled environments.
    - *Expected Outcome*: All attacks are neutralized with incidents logged.
    - *Actual Outcome*: 

- **TC6: Configuration and Setup Simplicity**
    - *Objective*: Determine ease of security setup and configuration.
    - *Steps*: Document the process of setting up and changing security settings.
    - *Expected Outcome*: Security setup is user-friendly with comprehensive documentation support.
    - *Actual Outcome*: 
    
- **TC7: Real-time Monitoring and Alerting Efficiency**
    - *Objective*: Test effectiveness of monitoring and alerting for security breaches.
    - *Steps*: Introduce test faults and observe monitoring and alert responses.
    - *Expected Outcome*: Immediate detection and notification of faults.
    - *Actual Outcome*: 

- **TC8: System Scalability with Security**
    - *Objective*: Evaluate scalability under increased load with full security measures.
    - *Steps*: Incrementally increase load and monitor system response.
    - *Expected Outcome*: System scales effectively, without compromising security.
    - *Actual Outcome*: 

- **TC9: Integration with New Security Tools**
    - *Objective*: Test flexibility in integrating new security solutions.
    - *Steps*: Add an external security tool and configure it to work with the existing setup.
    - *Expected Outcome*: Easy integration, enhancing the security framework.
    - *Actual Outcome*: 

- **TC10: Incident Response Effectiveness**
    - *Objective*: Evaluate the incident response plan for a security breach.
    - *Steps*: Simulate a breach and enact the incident response plan.
    - *Expected Outcome*: Quick and effective response to mitigate the breach impact.
    - *Actual Outcome*: 