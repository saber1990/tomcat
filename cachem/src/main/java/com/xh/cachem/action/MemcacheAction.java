package com.xh.cachem.action;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeoutException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import net.rubyeye.xmemcached.KeyIterator;
import net.rubyeye.xmemcached.MemcachedClient;
import net.rubyeye.xmemcached.MemcachedClientBuilder;
import net.rubyeye.xmemcached.XMemcachedClientBuilder;
import net.rubyeye.xmemcached.exception.MemcachedException;
import net.rubyeye.xmemcached.utils.AddrUtil;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;

import cn.news.xhcms.web.sso.utils.ResponseUtils;

import com.alibaba.fastjson.JSON;
import com.xinhuanet.session.MemcachedHttpSession;

@Controller
public class MemcacheAction {
	
	private String addr = "";
	private MemcachedClient memcachedClient = null;

	@RequestMapping(value = "/link.do")
	public void link(String linkStr, ModelMap model, HttpSession httpSession,
			HttpServletRequest request, HttpServletResponse response) {
		if (isClientSurvive()) {
			if (linkStr != null	&& linkStr.equals((String) httpSession.getAttribute("linkStr"))) {
				return;
			}
			try {
				memcachedClient.shutdown();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		if (linkStr == null) {
			httpSession.setAttribute("linkMsg", "连接失败..");
			return;
		}
		Map<String, String> map = new HashMap<String, String>();
		try {
			XMemcachedClientBuilder memcachedClientBuilder = new XMemcachedClientBuilder(AddrUtil.getAddresses(linkStr));
			memcachedClientBuilder.setOpTimeout(5000);
			memcachedClientBuilder.setConnectionPoolSize(20);
			memcachedClient = memcachedClientBuilder.build();
			if (memcachedClient == null) {
				map.put("linkMsg", "连接失败..");
			} else {
				memcachedClient.setEnableHeartBeat(false);
				map.put("linkMsg", "连接成功,当前memcached服务器:"
						+ linkStr);
				httpSession.setAttribute("linkMsg", "连接成功,当前memcached服务器:"
						+ linkStr);
				httpSession.setAttribute("linkStr", linkStr);
				addr = linkStr;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		ResponseUtils.renderJson(response, JSON.toJSONString(map));
	}

	@RequestMapping(value = "/removeCache.do")
	public void removeCache(String prefix, String key, ModelMap model,
			HttpSession httpSession, HttpServletRequest request,
			HttpServletResponse response) {
		if (!isClientSurvive() || httpSession.getAttribute("linkStr") == null) {
			httpSession.setAttribute("linkMsg", "请连接memcached服务器");
			return;
		}
		key = prefix + key;
		Map<String, String> map = new HashMap<String, String>();
		try {
			boolean isDelete = memcachedClient.delete(key.trim());
			if (isDelete) {
				map.put("success", "true");
			} else {
				map.put("success", "false");
			}
		} catch (TimeoutException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		} catch (MemcachedException e) {
			e.printStackTrace();
		}
		ResponseUtils.renderJson(response, JSON.toJSONString(map));
	}

	@RequestMapping(value = "/memFind.do")
	public void memFind(String prefix, String key, ModelMap model, HttpSession httpSession,
			HttpServletRequest request, HttpServletResponse response) {
		if (!isClientSurvive() || httpSession.getAttribute("linkStr") == null) {
			httpSession.setAttribute("linkMsg", "请连接memcached服务器");
			return;
		}
		key = prefix + key;
		
		Object o = null;
		List<Object> list = new ArrayList<Object>();
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			o = memcachedClient.get(key.trim());

			if (o instanceof MemcachedHttpSession) {
				MemcachedHttpSession memcachedHttpSession = (MemcachedHttpSession) o;
				String[] keys = memcachedHttpSession.getValueNames();
				for (String key_str : keys) {
					map.put(key_str, memcachedHttpSession.getValue(key_str));
				}
				list.add(map.toString());
			} else if (o instanceof ArrayList) {
				ArrayList arrayList = (ArrayList) o;
				for (Object oj : arrayList) {
					list.add(JSON.toJSONString(oj));
				}
			} else if (o instanceof HashSet) {
				HashSet set = (HashSet) o;
				for (Object oj : set) {
					list.add(JSON.toJSONString(oj));
				}
			} else if (o != null) {
				list.add(JSON.toJSONString(o));
			} else {
				list.add("memcachedClient得到null对象");
			}
		} catch (TimeoutException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		} catch (MemcachedException e) {
			e.printStackTrace();
		}
		ResponseUtils.renderJson(response, JSON.toJSONString(list));
	}
	
	
	@RequestMapping(value = "/memFind2nd.do")
	public void memFind2nd(String prefix, String key, String keyId, ModelMap model, HttpSession httpSession,
			HttpServletRequest request, HttpServletResponse response) {
		if (!isClientSurvive() || httpSession.getAttribute("linkStr") == null) {
			httpSession.setAttribute("linkMsg", "请连接memcached服务器");
			return;
		}
		List<Object> list = new ArrayList<Object>();
		try {
			KeyIterator it = memcachedClient.getKeyIterator(AddrUtil.getOneAddress(addr));
			int i = 0;
			String key2nd = "";
			
			if(keyId != null && !keyId.equals("")){
				//精确查找
				while (it.hasNext()) {
					key2nd = it.next();
					if (key2nd.startsWith(prefix) && key2nd.toLowerCase().contains("." + key.toLowerCase() + ":") && key2nd.endsWith(keyId)){
						list.add(key2nd);
						break;
					}
				}
			}else{
				while (it.hasNext()) {
					key2nd = it.next();
					if (key2nd.startsWith(prefix) && key2nd.toLowerCase().contains("." + key.toLowerCase() + ":")) {
						list.add(key2nd);
					}
				}
			}
		} catch (MemcachedException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		} catch (TimeoutException e) {
			e.printStackTrace();
		}
		if(list.size() == 0){
			list.add("memcachedClient未得到任何对象");
		}
		ResponseUtils.renderJson(response, JSON.toJSONString(list));
	}

	public boolean isClientSurvive() {
		if (memcachedClient == null || memcachedClient.isShutdown()) {
			return false;
		}
		return true;
	}
	
	public static void main(String[] args) {
		//192.168.86.81:11211
		//192.168.65.12:11211
		//xhcms.cache.memcache
		//xhcms_branch_0_2.cache.memcache
		MemcachedClientBuilder builder = new XMemcachedClientBuilder(
				AddrUtil.getAddresses("192.168.86.81:11211"));
		try {
			MemcachedClient memcachedClient = builder.build();
			KeyIterator it = memcachedClient.getKeyIterator(AddrUtil.getOneAddress("192.168.86.81:11211"));
			int i = 0;
			String key = "";
			while (it.hasNext()) {
				key = it.next();
				if (key.startsWith("xhcms_branch_0_2.cache.memcache") && !key.endsWith("key") && !key.contains("StandardQueryCache") && !key.contains("UpdateTimestampsCache")) {
//				if (key.contains(":")) {
					i++;
					Object o = memcachedClient.get(key);
					if(o == null){
						//continue;
					}
					System.out.println(key);
					System.out.println("---------" + o);
				}
			}
			System.out.println("===========" + i);
			memcachedClient.shutdown();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (MemcachedException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		} catch (TimeoutException e) {
			e.printStackTrace();
		}
		
	}

}
