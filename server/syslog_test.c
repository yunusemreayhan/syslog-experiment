#include <syslog.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    // Open syslog connection
    openlog("syslog_test", LOG_PID | LOG_CONS, LOG_USER);
    
    printf("Starting syslog test program...\n");
    
    // Send various log levels
    syslog(LOG_INFO, "This is an INFO message from the C program");
    syslog(LOG_WARNING, "This is a WARNING message from the C program");
    syslog(LOG_ERR, "This is an ERROR message from the C program");
    syslog(LOG_DEBUG, "This is a DEBUG message from the C program");
    syslog(LOG_NOTICE, "This is a NOTICE message from the C program");
    
    // Send logs in a loop
    int count = 0;
    while (1) {
        time_t now;
        time(&now);
        
        syslog(LOG_INFO, "Test message #%d at %s", ++count, ctime(&now));
        
        // Random log levels
        int level = rand() % 3;
        switch(level) {
            case 0:
                syslog(LOG_WARNING, "Random warning message #%d", count);
                break;
            case 1:
                syslog(LOG_ERR, "Random error message #%d", count);
                break;
            case 2:
                syslog(LOG_NOTICE, "Random notice message #%d", count);
                break;
        }
        
        printf("Sent log message #%d\n", count);
        
        // Sleep for 5 seconds
        sleep(5);
        
        // Stop after 20 messages
        if (count >= 20) {
            break;
        }
    }
    
    syslog(LOG_INFO, "Syslog test program ending");
    
    // Close syslog
    closelog();
    
    printf("Syslog test completed.\n");
    return 0;
}
