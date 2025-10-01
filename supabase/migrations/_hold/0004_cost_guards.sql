alter database postgres set statement_timeout = '15s';
alter database postgres set idle_in_transaction_session_timeout = '30s';
alter database postgres set log_min_duration_statement = '500ms';
alter database postgres set autovacuum_naptime = '30s';
