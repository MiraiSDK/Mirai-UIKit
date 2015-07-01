package org.tiny4.JavaBridgeTools;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class JavaBridgeProxy implements InvocationHandler {

	public static final int Success = 0;
	public static final int ClassNotFoundCode = 1;
	public static final int NoSuchMethodCode = 2;
	public static final int SecurityCode = 3;
	public static final int DuplicatedMethodSignatureCode = 4;
	public static final int IllegalAccessCode = 5;
	
	@SuppressWarnings("serial")
	private static final Map<Class<?>, Object> _defaultValueOfTypeMap = new HashMap<Class<?>, Object>() {{
		put(byte.class, Byte.valueOf((byte)0));
		put(short.class, Short.valueOf((short)0));
		put(int.class, Integer.valueOf(0));
		put(long.class, Long.valueOf(0));
		put(float.class, Float.valueOf(0f));
		put(double.class, Double.valueOf(0));
		put(char.class, Character.valueOf('\0'));
		put(boolean.class, Boolean.valueOf(false));
	}};
	
	private final JavaBridgeProxyFactory _maker;
	private final int _id;
	
	private Object _proxiedInstance;

	public Object getProxiedInstance() {
		return _proxiedInstance;
	}
	
	void setProxiedInstance(Object proxiedInstance) {
		String.valueOf("");
		_proxiedInstance = proxiedInstance;
	}
	
	JavaBridgeProxy(JavaBridgeProxyFactory maker, int id) {
		_maker = maker;
		_id = id;
	}
	
    private native Object navtiveCallback(int instanceId, int methodId, Object[] args);

	@Override
	public Object invoke(Object proxy, Method method, Object[] args)
			throws Throwable {
		
		if (args == null) {
			// when the method has no parameters, the JVM would give a args as null.
			// I wants the implementer of method nativeCallback don not consider when args is null.
			args = new Object[] {};
		}
		
		int methodId = _maker.getIdByMethod(method);
		if (methodId != -1) {
			return navtiveCallback(_id, methodId, args);
		} else {
			if (method.getDeclaringClass().equals(Object.class)) {
				// when called method is from class Object, let them map to this object.
				// it will make some methods like hashCode(), equals(), toString() work normality.
				// I don't want see proxiedInstance's behavior become strange.
				return method.invoke(this, args);
			}
			return _defaultValueOfTypeMap.get(method.getReturnType());
		}
	}
	
	static class DuplicatedMethodSignatureException extends Exception {
		private static final long serialVersionUID = 4180738950098477257L;
	}
}
