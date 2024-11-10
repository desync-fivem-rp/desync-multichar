export const debugData = (data) => {
    if (process.env.NODE_ENV === 'development') {
        window.invokeNative('debug', data);
    }
} 