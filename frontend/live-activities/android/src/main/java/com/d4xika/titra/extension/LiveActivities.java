package com.d4xika.titra.extension;

import com.getcapacitor.Logger;

public class LiveActivities {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
