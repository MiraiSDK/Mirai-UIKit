package org.tiny4.util;

import java.lang.NullPointerException;
import java.lang.RuntimeException;

public class SyncNode<ResultType> {

    private final Object syncLock = new Object();
    private ResultType result = null;

    public ResultType waitUtilGetResult() {
        synchronized (syncLock) {
            while (result == null) {
                try {
                    syncLock.wait();
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }
            ResultType rs = result;
            result = null;
            return rs;
        }
    }

    public void notifyAndSetResult(ResultType setResult) {
        if (setResult == null) {
            throw new NullPointerException("can't set null as result.");
        }
        synchronized (syncLock) {
            this.result = setResult;
            syncLock.notify();
        }
    }
}