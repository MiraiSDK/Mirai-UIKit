package org.tiny4.JavaBridgeTools;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.util.Log;

import org.tiny4.JavaBridgeTools.JavaBridgeProxy.DuplicatedMethodSignatureException;

public class JavaBridgeProxyFactory {
    
    private static String TAG = "JavaBridgeProxy";
    private static final ClassLoader _classLoader = JavaBridgeProxy.class.getClassLoader();
	
	@SuppressWarnings("serial")
	private static final Map<String, Class<?>> _primitiveTypeClasses = new HashMap<String, Class<?>>() {{
		put("void", void.class);
		put("byte", byte.class);
		put("short", short.class);
		put("int", int.class);
		put("long", long.class);
		put("float", float.class);
		put("double", double.class);
		put("char", char.class);
		put("boolean", boolean.class);
	}};
	
	private static int _resultCode = JavaBridgeProxy.Success;
	
	private final Map<Method, Integer> _method2IntegerMap;
	private final Constructor<?> _proxiedInstanceConstructor;
	
	public static int getResultCode() {
		return _resultCode;
	}
	
	public static JavaBridgeProxyFactory createFactory(String[] proxiedClassNames, String[] methodSignatures) {
		JavaBridgeProxyFactory factory = null;
		try {
			factory = new JavaBridgeProxyFactory(proxiedClassNames, methodSignatures);
			
		} catch (ClassNotFoundException e) {
            Log.i(TAG, e.toString());
			_resultCode = JavaBridgeProxy.ClassNotFoundCode;
			return null;
			
		} catch (NoSuchMethodException e) {
			Log.i(TAG, e.toString());
			_resultCode = JavaBridgeProxy.NoSuchMethodCode;
			return null;
			
		} catch (SecurityException e) {
			Log.i(TAG, e.toString());
			_resultCode = JavaBridgeProxy.SecurityCode;
			return null;
			
		} catch (DuplicatedMethodSignatureException e) {
			Log.i(TAG, e.toString());
			_resultCode = JavaBridgeProxy.DuplicatedMethodSignatureCode;
			return null;
		}
		_resultCode = JavaBridgeProxy.Success;
		return factory;
	}

	public JavaBridgeProxy createJavaBridgeProxy(int id) {
		JavaBridgeProxy proxy = new JavaBridgeProxy(this, id);
		try {
			proxy.setProxiedInstance(getProxiedInstance(proxy));
			
		} catch (IllegalAccessException e) {
			e.printStackTrace();
			_resultCode = JavaBridgeProxy.IllegalAccessCode;
			return null;
		}
		return proxy;
	}
	
	int getIdByMethod(Method method) {
		Integer id = _method2IntegerMap.get(method);
		if (id == null) {
			id = -1;
		}
		return id;
	}
	
	private JavaBridgeProxyFactory(String[] proxiedClassNames, String[] methodSignatures) 
			throws ClassNotFoundException, NoSuchMethodException, SecurityException, DuplicatedMethodSignatureException  {
		
		Class<?>[] proxiedinterfaces = findClassesByNames(proxiedClassNames);
		Class<?> proxyClass = Proxy.getProxyClass(_classLoader, proxiedinterfaces);
		
		Method[] methods = findMethodsBySignatures(proxiedinterfaces, methodSignatures);
		_method2IntegerMap = method2IndexMap(methods);
		_proxiedInstanceConstructor = proxyClass.getConstructor(InvocationHandler.class);
	}
	
	private Object getProxiedInstance(JavaBridgeProxy proxy) throws IllegalAccessException {
		try {
			return _proxiedInstanceConstructor.newInstance(proxy);
			
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
	
	private Class<?>[] findClassesByNames(String[] classNames) throws ClassNotFoundException {
		Class<?>[] classes = new Class[classNames.length];
		for (int i=0; i<classNames.length; ++i) {
			boolean initialize = true;
			classes[i] = Class.forName(classNames[i], initialize, _classLoader);
		}
		return classes;
	}
	
	private Method[] findMethodsBySignatures(Class<?>[] proxiedinterfaces, String[] methodSignatures)
			throws ClassNotFoundException, NoSuchMethodException, SecurityException, DuplicatedMethodSignatureException {
		
		Method[] methods = new Method[methodSignatures.length];
		for (int i=0; i<methodSignatures.length; ++i) {
			methods[i] = findMethodBySignature(proxiedinterfaces, methodSignatures[i]);
		}
		return methods;
	}
	
	private Map<Method, Integer> method2IndexMap(Method[] methods) {
		Map<Method, Integer> map = new HashMap<Method, Integer>();
		for (int i=0; i<methods.length; ++i) {
			map.put(methods[i], i);
		}
		return map;
	}
	
	private Method findMethodBySignature(Class<?>[] proxiedinterfaces, String methodSignature) 
			throws ClassNotFoundException, NoSuchMethodException, SecurityException, DuplicatedMethodSignatureException {
		
		String methodName = getMethodNameBySignature(methodSignature);
		String[] paramNames = getParamTypeNames(methodSignature);
		Class<?>[] paramTypes = new Class<?>[paramNames.length];
		for (int i=0; i<paramNames.length; ++i) {
			paramTypes[i] = getTypeClassByName(paramNames[i]);
		}
		Method foundMethod = null;
		for (Class<?> proxiedInterface : proxiedinterfaces) {
			try {
				Method method = proxiedInterface.getMethod(methodName, paramTypes);
				if (foundMethod != null) {
					throw new JavaBridgeProxy.DuplicatedMethodSignatureException();
				}
				foundMethod = method;
			} catch (NoSuchMethodException e) {
				// method may not belongs to this interface, there are a lot of interfaces.
			}
		}
		if (foundMethod == null) {
			throw new NoSuchMethodException();
		}
		return foundMethod;
	}
	
	private String getMethodNameBySignature(String methodSignature) {
		Pattern methodNamePattern = Pattern.compile("^(\\w|_)+");
		Matcher matcher = methodNamePattern.matcher(methodSignature);
		matcher.find();
		return matcher.group();
	}
	
	private String[] getParamTypeNames(String methodSignature) {
		String prefix = "^(\\w|_)+\\s*\\(";
		String postfix = "\\)$";
		String paramsPart = methodSignature.replaceAll(prefix, "").replaceAll(postfix, "");
		if (paramsPart.trim().equals("")) {
			return new String[] {};
		} else {
			String[] params = paramsPart.split("\\,");
			for (int i=0; i<params.length; ++i) {
				params[i] = params[i].trim();
			}
			return params;
		}
	}
	
	private Class<?> getTypeClassByName(String typeName) throws ClassNotFoundException {
		Class<?> type = _primitiveTypeClasses.get(typeName);
		if (type == null) {
			boolean initialize = true;
			type = Class.forName(typeName, initialize, _classLoader);
		}
		return type;
	}
}
