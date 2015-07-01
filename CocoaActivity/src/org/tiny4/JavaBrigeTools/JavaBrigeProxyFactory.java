package org.tiny4.JavaBrigeTools;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.tiny4.JavaBrigeTools.JavaBrigeProxy.DuplicatedMethodSignatureException;

public class JavaBrigeProxyFactory {

	private static final ClassLoader _classLoader = JavaBrigeProxy.class.getClassLoader();
	
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
	
	private static int _resultCode = JavaBrigeProxy.Success;
	
	private final Map<Method, Integer> _method2IntegerMap;
	private final Constructor<?> _proxiedInstanceConstructor;
	
	public static int getResultCode() {
		return _resultCode;
	}
	
	public static JavaBrigeProxyFactory createFactory(String[] proxiedClassNames, String[] methodSignatures) {
		JavaBrigeProxyFactory factory = null;
		try {
			factory = new JavaBrigeProxyFactory(proxiedClassNames, methodSignatures);
			
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			_resultCode = JavaBrigeProxy.ClassNotFoundCode;
			return null;
			
		} catch (NoSuchMethodException e) {
			e.printStackTrace();
			_resultCode = JavaBrigeProxy.NoSuchMethodCode;
			return null;
			
		} catch (SecurityException e) {
			e.printStackTrace();
			_resultCode = JavaBrigeProxy.SecurityCode;
			return null;
			
		} catch (DuplicatedMethodSignatureException e) {
			e.printStackTrace();
			_resultCode = JavaBrigeProxy.DuplicatedMethodSignatureCode;
			return null;
		}
		_resultCode = JavaBrigeProxy.Success;
		return factory;
	}
	
	public JavaBrigeProxy createJavaBrigeProxy(int id) {
		JavaBrigeProxy proxy = new JavaBrigeProxy(this, id);
		try {
			proxy.setProxiedInstance(getProxiedInstance(proxy));
			
		} catch (IllegalAccessException e) {
			e.printStackTrace();
			_resultCode = JavaBrigeProxy.IllegalAccessCode;
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
	
	private JavaBrigeProxyFactory(String[] proxiedClassNames, String[] methodSignatures) 
			throws ClassNotFoundException, NoSuchMethodException, SecurityException, DuplicatedMethodSignatureException  {
		
		Class<?>[] proxiedinterfaces = findClassesByNames(proxiedClassNames);
		Class<?> proxyClass = Proxy.getProxyClass(_classLoader, proxiedinterfaces);
		
		Method[] methods = findMethodsBySignatures(proxiedinterfaces, methodSignatures);
		_method2IntegerMap = method2IndexMap(methods);
		_proxiedInstanceConstructor = proxyClass.getConstructor(InvocationHandler.class);
	}
	
	private Object getProxiedInstance(JavaBrigeProxy proxy) throws IllegalAccessException {
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
					throw new JavaBrigeProxy.DuplicatedMethodSignatureException();
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
