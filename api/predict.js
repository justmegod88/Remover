export default async function handler(req,res){
 if(req.method!=="POST") return res.status(405).json({error:"POST only"});
 try{
  const token=process.env.REPLICATE_API_TOKEN;
  if(!token) return res.status(500).json({error:"Vercel 환경변수 REPLICATE_API_TOKEN이 없습니다."});
  const {image}=req.body||{};
  if(!image||!image.startsWith("data:image/")) return res.status(400).json({error:"이미지가 없습니다."});
  const version="storymy/take-off-eyeglasses:c6e2acbb2d27694609bccbf05cf3669959591b6da3ab78c8b51c6886a913c5bc";
  const r=await fetch("https://api.replicate.com/v1/predictions",{method:"POST",headers:{"Authorization":`Bearer ${token}`,"Content-Type":"application/json"},body:JSON.stringify({version,input:{image}})});
  const d=await r.json(); if(!r.ok)return res.status(r.status).json({error:d?.detail||d?.error||"Replicate 오류"});
  res.status(200).json({id:d.id,status:d.status});
 }catch(e){res.status(500).json({error:e.message||"서버 오류"})}
}