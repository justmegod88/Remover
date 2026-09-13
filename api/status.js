export default async function handler(req,res){
 if(req.method!=="GET")return res.status(405).json({error:"GET only"});
 try{
  const token=process.env.REPLICATE_API_TOKEN;if(!token)return res.status(500).json({error:"REPLICATE_API_TOKEN이 없습니다."});
  const id=req.query?.id;if(!id)return res.status(400).json({error:"prediction id가 없습니다."});
  const r=await fetch(`https://api.replicate.com/v1/predictions/${encodeURIComponent(id)}`,{headers:{"Authorization":`Bearer ${token}`}});
  const d=await r.json();if(!r.ok)return res.status(r.status).json({error:d?.detail||d?.error||"상태 확인 실패"});
  let out=d.output;if(Array.isArray(out))out=out[0];
  res.status(200).json({status:d.status,output:out||null,error:d.error||null});
 }catch(e){res.status(500).json({error:e.message||"서버 오류"})}
}